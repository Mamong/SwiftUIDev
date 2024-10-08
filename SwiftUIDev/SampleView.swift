//
//  SampleView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/15/24.
//

import MarkdownView
import SwiftUI

struct SampleView: View {
    let sample: Sample

    let showArticle: Bool

    @Binding var navigate: Bool

    @Environment(\.dismiss) private var dismiss

    @State private var showCode = false

    @State private var codeIndex = 0

    @State private var codeText = ""

    @State private var showSearch = false

    @State private var keyword = ""

    @State private var showCopyTips = false

    @StateObject private var controller: MarkdownUIController = MarkdownUIController()

    init(sample: Sample, keyword: String = "", navigate: Binding<Bool> = .constant(false), showArticle: Bool = false) {
        self.sample = sample
        self.showArticle = showArticle
        self._keyword = State(initialValue: keyword)
        ///需要搜索关键词时显示代码
        self._showCode = State(initialValue: !keyword.isEmpty)
        self._showSearch = State(initialValue: !keyword.isEmpty)
        self._navigate = navigate
    }

    var body: some View {
        NavigationStack {
            ZStack {
                if sample.id == "SampleText" {
                    SampleText()
                } else if sample.id == "SampleLabel" {
                    SampleLabel()
                } else if sample.id == "SampleTintColor" {
                    SampleTintColor()
                } else {
                    Text("Hello, World!").background(.background)
                }

                VStack {
                    VStack(spacing: 0) {
                        HStack(alignment: .bottom) {
                            ScrollView(Axis.Set.horizontal) {
                                HStack(spacing: 0){
                                    ForEach(0..<sample.codeFiles.count, id: \.self) { index in
                                        Label(sample.codeFiles[index], systemImage: "swift")
                                            .font(.system(size: 14))
                                            .padding(8)
                                            .background(Color.blue.opacity(codeIndex == index ? 0.4: 0.01), in: Rectangle())
                                            .onTapGesture {
                                                displayCode(at: index)
                                            }
                                    }
                                }
                            }
                            Button(action: {
                                showSearch.toggle()
                                if showSearch {
                                    controller.highlightAll(keyword: keyword)
                                }else{
                                    controller.removeAllHighlight()
                                }
                            }) {
                                Image(systemName: "magnifyingglass").padding(12)
                            }
                        }
                        Divider()
                    }
                    MarkdownUI2(controller: controller)
                        .overlay(alignment: .topTrailing){
                            ZStack(alignment:.trailing){
                                Button{
                                    showCopyTips = true
                                    UIPasteboard.general.string = codeText
                                    DispatchQueue.main.asyncAfter(deadline:.now()+1){
                                        showCopyTips = false
                                    }
                                } label: {
                                    Image(systemName: "doc.on.doc.fill")
                                }
                                Text("Copied")
                                    .padding(8)
                                    .background(in: RoundedRectangle(cornerRadius: 8))
                                    .allowsHitTesting(false)
                                ///https://stackoverflow.com/questions/72253021/what-is-this-odd-error-in-the-console-ignoring-singular-matrix
                                    .scaleEffect(showCopyTips ? 1.0:0.001)
                                    .animation(.default, value: showCopyTips)
                            }
                            .offset(x:-25, y: 20)
                        }
                    if showSearch {
                        ArticleToolView(keyword: $keyword, controller: controller, onDone: { showSearch = false })
                            .transition(.move(edge: .bottom))
                            .ignoresSafeArea(.keyboard, edges: .bottom)
                    }
                }
                .animation(.easeOut(duration: 0.1), value: showSearch)
                .background().zIndex(showCode ? 1 : -1)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done", action: {
                        dismiss()
                    })
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    if showArticle {
                        Button(action: {
                            dismiss()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                navigate = true
                            }
                        }) {
                            Image(systemName: "text.book.closed")
                        }
                    }
                    Button(action: {
                        showCode.toggle()
                    }) {
                        Image(showCode ? "code_hl":"code").resizable().frame(width:28,height:28)
                    }
                }
            }
            .onAppear {
                displayCode(at: codeIndex)
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle(sample.name)
        }
    }

    func displayCode(at index:Int) {
        codeIndex = index
        codeText =  sample.loadCode(sample.codeFiles[index])
        controller.text = codeText.codeToMarkdown()
        if showSearch{
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                controller.highlightAll(keyword: keyword)
            }
        }
    }
}

struct SampleView_Previews: PreviewProvider {
    static var previews: some View {
        SampleView(sample: samples[0], navigate: .constant(false))
    }
}
