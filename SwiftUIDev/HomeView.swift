//
//  HomeView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            List(menus, children: \.children) { menu in
                if menu.children != nil {
                    HStack {
                        Image(systemName: menu.icon)
                        Text(menu.name)
                    }
                    .foregroundStyle(.blue)
                } else {
                    NavigationLink {
                        ArticleView(article: menu.article!)
                            .toolbar(.hidden, for: .tabBar)
                    } label: {
                        HStack {
                            Image(systemName: menu.icon).foregroundStyle(.blue)
                            Text(menu.name)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            .font(.system(size: 16))
            .navigationTitle("Home")
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
