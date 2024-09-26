//
//  MarkdownUI2.swift
//  SwiftUIDev
//
//  Created by tryao on 9/17/24.
//
import MarkdownView
import SwiftUI
import UIKit


/// ObservableObject存在缺陷，highlightPos变动会导致引用MarkdownUIController本身的视图也发生重建
/// iOS 17 Observable没有此缺陷，旧版本暂无好的处理办法
public class MarkdownUIController: ObservableObject {
    private(set) var markdown: MarkdownView!

    public var text: String = "" {
        didSet {
            markdown.show(markdown: text)
        }
    }

//    public var current = 0
//    public var total = 0

    private(set) var hasClient = false

    @Published public var highlightPos:String = ""

    /// 更好的做法，但实现困难
//    @Binding var highlightPos:String
//
//    public init(highlightPos:Binding<String> = .constant("")) {
//        self._highlightPos = highlightPos
//    }

    public func bindTo(view: MarkdownView) {
        markdown = view
        hasClient = true
    }

    public func highlightPrev() {
        markdown.evaluate("WKWebView_SearchPrev();[currSelected,WKWebView_SearchResultCount]", completionHandler: { result, _ in
            if let result = result as? [Int] {
                self.highlightPos = "\(result[0]+1)/\(result[1])"
//                self.current = result[0]+1
//                self.total = result[1]
            }
        })
    }

    public func highlightNext() {
        markdown.evaluate("WKWebView_SearchNext();[currSelected,WKWebView_SearchResultCount]", completionHandler: { result, _ in
            if let result = result as? [Int] {
                self.highlightPos = "\(result[0]+1)/\(result[1])"
                // self.current = result[0]+1
                // self.total = result[1]
            }
        })
    }

    public func highlightAll(keyword: String) {
        guard !keyword.isEmpty else { return }
        markdown.evaluate("WKWebView_HighlightAllOccurencesOfString('\(keyword)');[currSelected,WKWebView_SearchResultCount]", completionHandler: { result, _ in
            if let result = result as? [Int] {
                let total = result[1]
                if total > 0 {
                    self.markdown.evaluate("WKWebView_SearchNext();", completionHandler: nil)
                    self.highlightPos = "1/\(result[1])"
                } else {
                    self.highlightPos = ""
                }
            }
        })
    }

    public func removeAllHighlight() {
        markdown.evaluate("WKWebView_RemoveAllHighlights()", completionHandler: nil)
        // self.current = 0
        // self.total = 0
        highlightPos = ""
    }
}

public struct MarkdownUI2: UIViewRepresentable, Equatable {

    private let text: String

    private var onTouchLink: (URLRequest) -> Bool = { _ in true }

    private var onRendered: (CGFloat) -> Void = { _ in }

    private var controller: MarkdownUIController?

    /// 可以通过text作为初次加载的内容
    public init(text: String = "", controller: MarkdownUIController?) {
        self.text = text
        self.controller = controller
    }

    /// 仅在text发生变化的时候，才触发updateUIView
    public static func == (lhs: MarkdownUI2, rhs: MarkdownUI2) -> Bool {
        lhs.text == rhs.text
    }

    public func makeUIView(context: Context) -> MarkdownView {
        let markdown = MarkdownViewPool.shared.pick()
        markdown.onRendered = onRendered
        markdown.onTouchLink = onTouchLink

        let filePath = Bundle.main.path(forResource: "SearchWebView", ofType: "js")!
        let script2 = try! String(contentsOfFile: filePath, encoding: .utf8)
        markdown.evaluate(script2)
        controller?.bindTo(view: markdown)
        return markdown
    }

    /// 已使用MarkdownView池对Webview进行预热优化
    /// 极致的体验可使用预渲染，就是在导航发生前提前渲染
    public func updateUIView(_ uiView: MarkdownView, context: Context) {
        print("updateUIView")
        controller?.text = text
    }

    public static func dismantleUIView(_ uiView: MarkdownView, coordinator: ()) {}
}

extension MarkdownUI2 {
    func onTouchLink(_ action: @escaping (URLRequest) -> Bool) -> Self {
        then {
            $0.onTouchLink = action
        }
    }

    func onRendered(_ action: @escaping (CGFloat) -> Void) -> Self {
        then {
            $0.onRendered = action
        }
    }
}

extension View {
    func then(_ body: (inout Self) -> Void) -> Self {
        var result = self
        body(&result)
        return result
    }
}

class MarkdownViewPool {
    static let shared = MarkdownViewPool()

//    private var itemId = 0

    private var list: [MarkdownView] = []

    public func populate() {
        let script1 = """
            document.body.style.webkitUserSelect = 'none';
            document.body.style.userSelect = 'none';
        """

        let markdownView = MarkdownView(css: nil, plugins: [script1], stylesheets: nil, styled: true)
        markdownView.isScrollEnabled = true
        list.append(markdownView)
    }

    public func pick() -> MarkdownView {
        if list.count <= 1 {
            populate()
        }
        return list.removeFirst()
    }

//    public func pick() -> MarkdownView {
//        let firstIndex = list.firstIndex(where: { $0.tag == 0 })
//        let lastIndex = list.lastIndex(where: { $0.tag == 0 })
//
//        //没有可用或者只有一个
//        if firstIndex == lastIndex  {
//            populate()
//        }
//
//        var item:MarkdownView
//        if let firstIndex {
//            //有一个或多个可用
//            item = list[firstIndex]
//        }else{
//            //没有可用，返回新建的
//            item = list.last!
//        }
//        itemId += 1
//        item.tag = itemId
//        return item
//    }
//
//    public func renew(item:MarkdownView){
//        item.show(markdown: "")
//        item.tag = 0
//    }
}
