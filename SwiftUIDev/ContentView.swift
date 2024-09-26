//
//  ContentView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import SwiftUI

enum AppearanceMode: Int {
    case system, light, dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct ContentView: View {
    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    var body: some View {
        TabView {
            HomeView().tabItem {
                Label("Home", systemImage: "house")
            }

            SamplesView().tabItem {
                Label("Samples", systemImage: "curlybraces")
            }

            SearchView().tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }

            SettingsView().tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
//        .environment(\.locale,Locale(identifier: "zh"))
        .preferredColorScheme(appearance.colorScheme)
        .onAppear {
            MarkdownViewPool.shared.populate()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
