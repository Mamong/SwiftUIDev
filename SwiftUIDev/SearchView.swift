//
//  SearchView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/20/24.
//

import Combine
import SwiftUI

struct SearchView: View {
    @State private var keyword = ""

    @State private var scope = 0

    @State private var alist: [Article] = []

    @State private var slist: [Sample] = []

    /// combine debunce vs .task
    private let searchTextPublisher = PassthroughSubject<String, Never>()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if keyword.isEmpty {
                    Text("Exact match, word is case insensitive").foregroundColor(.gray)
                } else {
                    if scope == 0 {
                        articleListView
                    } else if scope == 1 {
                        SampleListView(samples: slist, keyword: keyword)
                    }
                }
            }
            .navigationTitle("Search")
        }
        .searchable(text: $keyword, prompt: Text("global search"))
        .searchScopes($scope) {
            Text("article").tag(0)
            Text("sample").tag(1)
        }
        .task(id: keyword) {
            do {
                try await Task.sleep(nanoseconds: 500_000_000)
                search(matching: keyword)
            } catch {
                // Task cancelled without search.
            }
        }
//        .onChange(of: keyword) { newValue in
//            searchTextPublisher.send(newValue)
//        }
//        .onReceive(searchTextPublisher.debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)) { newValue in
//            search(matching: newValue)
//        }
    }

    var articleListView: some View {
        List(alist) { article in
            NavigationLink {
                ArticleView(article: article, keyword: keyword)
                    .toolbar(.hidden, for: .tabBar)
            } label: {
                HStack {
                    Image(systemName: "doc.text").foregroundStyle(.blue)
                    Text(article.name)
                }
            }
        }
        .font(.system(size: 16))
    }

    func search(matching: String) {
        if matching.isEmpty {
            alist = []
            slist = []
            return
        }
        alist = articles.filter { item in
            item.loadMarkdown(fixPath: false).range(of: matching, options: String.CompareOptions.caseInsensitive) != nil
        }
        slist = samples.filter { item in
            item.codeFiles.contains(where: { code in
                item.loadCode(code).range(of: matching, options: String.CompareOptions.caseInsensitive) != nil
            })
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
