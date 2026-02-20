//
//  AddCitiesView.swift
//  Breezy
//
//  Created by Mian Usama on 21/02/2026.
//

import SwiftUI

struct AddCitiesView: View {
    let router: AppRouter
    
    @State private var searchText: String = ""
    @FocusState private var isSearchFocused: Bool
    
    // Demo data (replace later with presenter data)
    @State private var cities: [CityItem] = [
        CityItem(name: "Pakistan", subtitle: "My Location", temp: "15°", high: "28°", low: "13°"),
        CityItem(name: "Islamabad", subtitle: "12:50 AM", temp: "14°", high: "25°", low: "12°")
    ]
    
    var filteredCities: [CityItem] {
        if searchText.isEmpty { return cities }
        return cities.filter {
            $0.name.localizedCaseInsensitiveContains(searchText)
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
                ScrollView(showsIndicators: false){
                    VStack(spacing: 15){
                        ForEach(filteredCities){ city in
                            CityCardView(city: city)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 10)
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
            
            Image(systemName: "mic")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 20)
        .liquidGlassEffect(in:  RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
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
                Text("Clear")
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
    let id = UUID()
    let name: String
    let subtitle: String
    let temp: String
    let high: String
    let low: String
}
