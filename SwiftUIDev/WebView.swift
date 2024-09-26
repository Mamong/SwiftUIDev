//
//  WebView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    var html: String

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        webView.loadHTMLString(html, baseURL: nil)
    }
}
