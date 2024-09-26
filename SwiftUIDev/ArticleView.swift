//
//  MarkdownView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import MarkdownView
import SwiftUI

struct ArticleView: View {
    let article: Article

    @State private var present = false

    @State private var navigate = false

    @State private var linkId = ""

    @State private var showSearch = false

    @State private var keyword = ""

    @StateObject private var controller: MarkdownUIController = MarkdownUIController()

    init(article: Article, keyword: String = "") {
        self.article = article
        self._keyword = State(initialValue: keyword)
        self._showSearch = State(initialValue: !keyword.isEmpty)
    }

    var body: some View {
        VStack {
            MarkdownUI2(controller: controller)
                .onTouchLink { link in
                    print(link)
                    linkId = String(link.url!.absoluteString.split(separator: "//")[1])
                    if let scheme = link.url?.scheme {
                        if scheme == "sample" {
                            present = true
                        } else if scheme == "post" {
                            navigate = true
                        } else {
                            UIApplication.shared.open(link.url!, options: [:], completionHandler: nil)
                        }
                    }
                    return false
                }
                .onRendered { height in
                    print(height)
                }
            if showSearch {
                ArticleToolView(keyword: $keyword, controller: controller, onDone: {
                    showSearch = false
                })
                .ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .toolbar {
            ToolbarItem {
                Button(action: {
                    showSearch.toggle()
                    if showSearch {
                        controller.highlightAll(keyword: keyword)
                    }else{
                        controller.removeAllHighlight()
                    }
                }) {
                    Image(systemName: "magnifyingglass")
                }
            }
            if !article.samples.isEmpty {
                ToolbarItem {
                    Menu {
                        ForEach(article.samples, id: \.self) { sample in
                            Button(sample, action: {
                                linkId = sample
                                present = true
                            })
                        }
                    } label: {
                        Image(systemName: "curlybraces")
                    }
                }
            }
        }
        .navigationDestination(isPresented: $navigate) {
            if let article = articles.first(where: {
                $0.id == linkId
            }) {
                ArticleView(article: article)
            } else {
                Text("该文章不存在")
            }
        }
        .sheet(isPresented: $present) {
            if let sample = samples.first(where: {
                $0.id == linkId
            }) {
                SampleView(sample: sample)
            } else {
                Text("该代码不存在")
            }
        }
        .navigationTitle(article.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            controller.text = article.loadMarkdown()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                controller.highlightAll(keyword: keyword)
            }
        }
    }
}

struct ArticleToolView: View {
    @Binding var keyword: String

    @ObservedObject var controller: MarkdownUIController

    var onDone: () -> Void

    @FocusState private var focus: Bool

    var body: some View {
        HStack {
            Button("Done") {
                controller.removeAllHighlight()
                onDone()
            }
            TextField("", text: $keyword, prompt: Text("content search"))
                .textFieldStyle(.roundedBorder)
                .focused($focus)
                .onChange(of: keyword) { _ in
                    if keyword.isEmpty {
                        controller.removeAllHighlight()
                    } else {
                        controller.highlightAll(keyword: keyword)
                    }
                }
                .onAppear {
                    focus = keyword.isEmpty
                }
            Text(controller.highlightPos)
            Button {
                controller.highlightPrev()
            } label: {
                Image(systemName: "chevron.up").padding(4)
            }
            .disabled(controller.highlightPos.isEmpty)

            Button {
                controller.highlightNext()
            } label: {
                Image(systemName: "chevron.down").padding(4)
            }
            .disabled(controller.highlightPos.isEmpty)
        }
        .padding()
        .background(.background)
    }
}

struct SDMarkdownView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ArticleView(article: articles[0])
        }
    }
}
