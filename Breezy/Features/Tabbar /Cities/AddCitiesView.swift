//
//  AddCitiesView.swift
//  Breezy
//
//  Created by Mian Usama on 21/02/2026.
//

import SwiftUI

struct AddCitiesView: View {
    let router: AppRouter
    @EnvironmentObject var presenter: HomePresenter
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    /// Demo data (replace later with presenter data)
    private var cityItems: [CityItem]{
        presenter.cityWeathers.enumerated().map { index, vm in
            CityItem(
                id: vm.id,
                name: vm.city,
                subtitle: index == 0 ? "My Location" : cityCurrentTime(timeZone: vm.timezone),
                temp: vm.temperature,
                high: vm.high,
                low: vm.low,
                condition: vm.condition,
                isDeletable: index != 0
            )
        }
    }

    var body: some View {
        ZStack {
            GeometryReader { geometry in
                Image("background")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 10){
                /// Search Bar
                searchBar
                /// Cities List
                List {
                    ForEach(cityItems){ city in
                        CityCardView(city: city)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true){
                                if city.isDeletable {
                                    Button {
                                        deleteCity(city)
                                    } label: {
                                        Image(systemName: "trash")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 20, height: 20)
                                    }
                                    .tint(.red)
                                }
                            }
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
                    }
                }
                .listStyle(.plain)
            }
            .padding(.top, 10)
        }
        .task {
            if presenter.cities.isEmpty {
                await presenter.addCity("Islamabad")
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white.opacity(0.7))
            
            TextField("Search for a city or airport", text: $searchText)
                .foregroundColor(.white)
                .focused($isSearchFocused)
                .submitLabel(.search)
                .onSubmit {
                    Task {
                        await presenter.addCity(searchText)
                        searchText = ""
                    }
                }
            
            Image(systemName: "mic")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .liquidGlassEffect(in:  RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
    
    private func deleteCity(_ city: CityItem){
        guard let index = presenter.cityWeathers.firstIndex(where: { $0.id == city.id }) else { return }
        presenter.cityWeathers.remove(at: index)
        presenter.cities.remove(at: index)
    }
    
    private func cityCurrentTime(timeZone: Int) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        /// Create timezone from seconds offset
        if let tz = TimeZone(secondsFromGMT: timeZone){
            formatter.timeZone = tz
        }
        return formatter.string(from: Date())
    }
}

struct CityCardView: View {
    let city: CityItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15){
            HStack(alignment: .top){
                VStack(alignment: .leading, spacing: 2){
                    Text(city.name)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Text(city.subtitle)
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
                }
                Spacer()
                Text(city.temp)
                    .font(.system(size: 42, weight: .light))
                    .foregroundColor(.white)
            }
            HStack {
                Text(city.condition)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("H:\(city.high)  L:\(city.low)")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
            }
        }
        .padding(.horizontal, 18)
        .padding(.vertical, 14)
        .liquidGlassEffect(in: RoundedRectangle(cornerRadius: 20))
    }
}

struct CityItem: Identifiable {
    let id: UUID
    let name: String
    let subtitle: String
    let temp: String
    let high: String
    let low: String
    let condition: String
    let isDeletable: Bool
}
