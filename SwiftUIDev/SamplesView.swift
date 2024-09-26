//
//  SamplesView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/15/24.
//

import SwiftUI

struct SamplesView: View {
    var body: some View {
        NavigationStack {
            SampleListView(samples: samples)
                .navigationTitle("Samples")
        }
    }
}

struct SampleListView: View {
    var samples: [Sample]

    var keyword = ""

    @AppStorage("appearance") private var appearance: AppearanceMode = .system

    @State private var sample: Sample?

    @State private var navigate = false

    @State private var present = false

    var body: some View {
        List(samples, id: \.id) { item in
            Button {
                present = true
                sample = item
            } label: {
                HStack {
                    Image(systemName: "curlybraces")
                    Text(item.name).foregroundStyle(.primary)
                }
            }
        }
        .navigationDestination(isPresented: $navigate) {
            if let sample, let article = articles.first(where: {
                $0.id == sample.article
            }) {
                ArticleView(article: article).toolbar(.hidden, for: .tabBar)
            }
        }
        .sheet(isPresented: $present) {
            if let sample {
                SampleView(sample: sample, keyword: keyword, navigate: $navigate, showArticle: true)
                    .preferredColorScheme(appearance.colorScheme)
            }
        }
    }
}

struct SamplesView_Previews: PreviewProvider {
    static var previews: some View {
        SamplesView()
    }
}
