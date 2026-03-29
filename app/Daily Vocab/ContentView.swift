//
//  ContentView.swift
//  Daily Vocab
//
//  Created by Tanner Cheek on 2/19/26.
//

import SwiftUI

struct ContentView: View {
  @AppStorage("appearance") private var appearance: String = "system"
    
    init() {
            let largeTitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "InstrumentSerif-Regular", size: 36)!
            ]
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: "InstrumentSerif-Regular", size: 17)!
            ]
            UINavigationBar.appearance().largeTitleTextAttributes = largeTitleAttributes
            UINavigationBar.appearance().titleTextAttributes = titleAttributes
        }

  var body: some View {
    TabView {
      NavigationStack { HomeView() }
        .tabItem {
          Label {
            Text("Today")
          } icon: {
            Image("DS.Icon.Home")
              .renderingMode(.template)
          }
        }

      NavigationStack { ReviewView() }
        .tabItem {
          Label {
            Text("Review")
          } icon: {
            Image("DS.Icon.Cards")
              .renderingMode(.template)
          }
        }

      NavigationStack { MyWordsView() }
        .tabItem {
          Label {
            Text("My Words")
          } icon: {
            Image("DS.Icon.Bookmark")
              .renderingMode(.template)
          }
        }

      NavigationStack { SettingsView() }
        .tabItem {
          Label {
            Text("Settings")
          } icon: {
            Image("DS.Icon.Settings")
              .renderingMode(.template)
          }
        }
    }
    .tint(DS.Color.accent)
    .toolbarBackground(DS.Color.surface, for: .tabBar)
    .toolbarBackground(.visible, for: .tabBar)
    .preferredColorScheme(colorSchemeFromPreference(appearance))
  }

  private func colorSchemeFromPreference(_ value: String) -> ColorScheme? {
    switch value {
    case "light": return .light
    case "dark": return .dark
    default: return nil
    }
  }
}

#Preview {
    ContentView()
        .background(DS.Color.background)
}

