//
//  HomeView.swift
//  Breezy
//
//  Created by Mian Usama on 13/10/2025.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var presenter: HomePresenter
    @State private var showAddCity = false
    
    init(){
        let interactor = WeatherInteractor(service: WeatherService.shared)
        _presenter = StateObject(wrappedValue: HomePresenter(interactor: interactor))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient()
                    .ignoresSafeArea()
                
                VStack {
                    headerBar()
                    if presenter.cityWeathers.isEmpty {
                        Spacer()
                        VStack(spacing: 12){
                            Text("No weather data")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.9))
                            Text("Add a city to start seeing weather")
                                .foregroundColor(.white.opacity(0.8))
                            Button(action: { showAddCity = true }) {
                                Label("Add City", systemImage: "plus")
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 10)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                            }
                        }
                        Spacer()
                    } else {
                        TabView(selection: $presenter.selectedCityIndex){
                            ForEach(Array(presenter.cityWeathers.enumerated()), id: \.offset){ index, vm in
                                WeatherCityCard(cityVM: vm)
                                    .tag(index)
                                    .padding(.horizontal)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .indexViewStyle(.page(backgroundDisplayMode: .always))
                    }
                }
                .padding(.top)
                .sheet(isPresented: $showAddCity){
                    AddCityView { city in
                        Task {
                            await presenter.addCity(city)
                        }
                        showAddCity = false
                    }
                }
                .task {
                    await presenter.loadAllSavedCities()
                }
                .overlay(alignment: .topTrailing){
                    Button(action: {
                        showAddCity = true
                    }){
                        Image(systemName: "plus")
                            .font(.title2)
                            .padding(10)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                    .padding()
                }
            }
            .navigationTitle("Breezy")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    // MARK: Subviews
    
    @ViewBuilder
    private func headerBar() -> some View {
        VStack(spacing: 10){
            HStack {
                Text(currentCityName())
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                Spacer()
                if presenter.isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                }
            }
            .padding(.horizontal)
            
            if let vm = currentCityVM(){
                HStack(spacing: 16) {
                    Image(systemName: vm.iconName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80)
                        .foregroundColor(.white)
                        .background(.ultraThinMaterial.opacity(0.05))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text(vm.temperature)
                            .font(.system(size: 52, weight: .semibold))
                            .foregroundColor(.white)
                        Text(vm.condition)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    Spacer()
                    Text(vm.highLow)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.horizontal)
            } else {
                HStack {
                    VStack(alignment: .leading){
                        Text("--°").font(.system(size: 52, weight: .semibold)).foregroundColor(.white)
                        Text("—").foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                }
                .padding(.horizontal)
            }
        }
        .padding(.top, 6)
    }
    
    @ViewBuilder
    private func WeatherCityCard(cityVM: HomePresenter.CityWeatherViewModel) -> some View {
        ScrollView {
            VStack(spacing: 18){
                ScrollView(.horizontal, showsIndicators: false){
                    HStack(spacing: 12){
                        ForEach(cityVM.hourly){ h in
                            VStack(spacing: 8){
                                Text(h.hourLabel).foregroundColor(.white.opacity(0.9)).font(.subheadline)
                                Image(systemName: h.iconName).font(.title2).foregroundColor(.white)
                                Text(h.temp).foregroundColor(.white).font(.headline)
                            }
                            .padding()
                            .background(.ultraThinMaterial)
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                }
                
                VStack(spacing: 8){
                    ForEach(cityVM.daily){ d in
                        HStack {
                            Text(d.dayLabel).foregroundColor(.white)
                            Spacer()
                            Image(systemName: d.iconName).foregroundColor(.white)
                            Spacer()
                            Text(d.max).foregroundColor(.white)
                            Text(d.min).foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 80)
            }
            .padding(.top, 12)
        }
    }
    
    // helpers
    private func currentCityVM() -> HomePresenter.CityWeatherViewModel? {
        guard presenter.cityWeathers.indices.contains(presenter.selectedCityIndex) else { return nil }
        return presenter.cityWeathers[presenter.selectedCityIndex]
    }
    
    private func currentCityName() -> String {
        if let vm = currentCityVM(){ return vm.city }
        return "Breezy"
    }
    
    private func backgroundGradient() -> LinearGradient {
        if let vm = currentCityVM(), vm.iconName.contains("sun"){
            return LinearGradient(colors: [Color.blue, Color.cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        } else {
            return LinearGradient(colors: [Color.gray, Color.blue.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

// MARK: - Add City view (sheet)
struct AddCityView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var cityName: String = ""
    var onAdd: (String) -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16){
                TextField("Enter city name", text: $cityName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(action: {
                    let trimmed = cityName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !trimmed.isEmpty else { return }
                    onAdd(trimmed)
                    dismiss()
                }){
                    Text("Add City")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Add City")
            .toolbar {
                ToolbarItem(placement: .cancellationAction){
                    Button("Close"){
                        dismiss()
                    }
                }
            }
        }
    }
}
