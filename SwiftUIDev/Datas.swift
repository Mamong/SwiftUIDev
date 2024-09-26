//
//  Datas.swift
//  SwiftUIDev
//
//  Created by tryao on 9/18/24.
//

import Foundation

struct MenuItem: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let children: [MenuItem]?

    var article: Article? {
        articles.first(where: { $0.name == name })
    }
}

struct Sample: Identifiable {
    let id: String
    let name: String

    let article: String
    let codeFiles: [String]

    func loadCode(_ title: String, markdown: Bool = false) -> String {
        let components = title.split(separator: ".")
        if let bundlePath = Bundle.main.path(forResource: "Code", ofType: "bundle"),
           let bundle = Bundle(path: bundlePath),
           let filePath = bundle.path(forResource: String(components[0]), ofType: String(components[1])),
           let content = try? String(contentsOfFile: filePath, encoding: .utf8)
        {
            if markdown {
                return content.codeToMarkdown()
            }else{
                return content
            }
        } else {
            return "无法读取文件"
        }
    }
}

struct Article: Identifiable {
    let id: String
    let name: String
    let samples: [String]

    var fileName: String {
        "\(id) \(name)"
    }

    func loadMarkdown(fixPath:Bool = true) -> String {
        if let filePath = Bundle.main.path(forResource: fileName, ofType: "md"),
           let content = try? String(contentsOfFile: filePath, encoding: .utf8)
        {
            if fixPath {
                return replaceImageNamesWithPaths(markdown: content)
            }else{
                return content
            }
        } else {
            return "无法读取文件"
        }
    }

    private func replaceImageNamesWithPaths(markdown: String) -> String {
        do {
            let basePath = Bundle.main.bundlePath + "/"
            let pattern = "!\\[.*\\]\\((.*)\\)"
            // 匹配Markdown中的图片语法 ![alt](image_name)
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: markdown, range: NSRange(markdown.startIndex..., in: markdown))

            var modifiedMarkdown = markdown
            // 从后往前处理，保证range有效
            for result in results.reversed() {
                if let range = Range(result.range(at: 1), in: markdown) {
                    let imageName = String(markdown[range])
                    let fullPath = basePath + imageName
                    modifiedMarkdown.replaceSubrange(range, with: fullPath)
                }
            }
            return modifiedMarkdown
        } catch {
            print("Invalid regex: \(error.localizedDescription)")
            return markdown
        }
    }
}

extension String {
//    func displayCodeName() -> Self {
//        if starts(with: "Sample") {
//            return String(trimmingPrefix("Sample"))
//        }
//        return self
//    }
//
//    func fileDisplayedName() -> Self {
//        return String(split(separator: " ", maxSplits: 1)[1])
//    }

    func codeToMarkdown(lang:String = "swift") -> Self{
        "```\(lang)\n" + self + "\n```"
    }
}

let menus = [
    MenuItem(name: "SwiftUI", icon: "square.stack.3d.down.right", children: [
        MenuItem(name: "App结构与基础概念", icon: "square", children: [
            MenuItem(name: "App 入口与配置", icon: "doc.text", children: nil),
        ]),
        MenuItem(name: "基础视图及使用", icon: "rectangle.on.rectangle", children: [
            MenuItem(name: "文本-Text", icon: "doc.text", children: nil),
            MenuItem(name: "文本-Label", icon: "doc.text", children: nil),
        ]),
        MenuItem(name: "视图容器与布局", icon: "square.stack", children: []),
        MenuItem(name: "绘图与动画", icon: "paintpalette", children: []),
        MenuItem(name: "手势", icon: "hand.tap", children: []),
    ]),
    MenuItem(name: "Concurrency", icon: "distribute.vertical.center", children: [
        MenuItem(name: "async/await", icon: "list.bullet", children: []),
        MenuItem(name: "Tasks", icon: "list.bullet", children: []),
        MenuItem(name: "Asynchronous Sequences", icon: "list.bullet", children: []),
        MenuItem(name: "Actors", icon: "list.bullet", children: []),
    ]),
    MenuItem(name: "Combine", icon: "point.3.connected.trianglepath.dotted", children: [
        MenuItem(name: "引言", icon: "list.bullet", children: []),
        MenuItem(name: "Publishers", icon: "list.bullet", children: []),
        MenuItem(name: "Subscribers", icon: "list.bullet", children: [
            //MenuItem(name: "Subscriber 的详细介绍", icon: "doc.text", children: nil),

        ]),
        MenuItem(name: "Operators", icon: "list.bullet", children: []),
    ]),
    MenuItem(name: "Swift", icon: "swift", children: [
        // MenuItem(name: "Swift 6.0 新特性",icon: "doc.text",children: nil),
        MenuItem(name: "Swift 5.9 新特性", icon: "doc.text", children: nil),
        MenuItem(name: "Swift 5.8 新特性", icon: "doc.text", children: nil),
        MenuItem(name: "Swift 中的 Result builders", icon: "doc.text", children: nil),
        MenuItem(name: "Swift 中的不透明类型和存在类型", icon: "doc.text", children: nil),
        MenuItem(name: "Swift 5.7 新特性", icon: "doc.text", children: nil),
    ]),
]

let articles = [
    Article(id: "1.1.1", name: "App 入口与配置", samples: ["SampleTintColor"]),
    Article(id: "1.2.1.1", name: "文本-Text", samples: ["SampleText"]),
    Article(id: "1.2.1.2", name: "文本-Label", samples: ["SampleLabel"]),


    Article(id: "4.5", name: "Swift 5.9 新特性", samples: []),
    Article(id: "4.4", name: "Swift 5.8 新特性", samples: []),
    Article(id: "4.3", name: "Swift 中的 Result builders", samples: []),
    Article(id: "4.2", name: "Swift 中的不透明类型和存在类型", samples: []),
    Article(id: "4.1", name: "Swift 5.7 新特性", samples: []),

]

let samples = [
    Sample(id: "SampleTintColor", name: "TintColor", article: "1.1.1", codeFiles: ["SampleTintColor.swift"]),
    Sample(id: "SampleText", name: "Text", article: "1.2.1.1", codeFiles: ["SampleText.swift"]),
    Sample(id: "SampleLabel", name: "Label", article: "1.2.1.2", codeFiles: ["SampleLabel.swift"]),
]
