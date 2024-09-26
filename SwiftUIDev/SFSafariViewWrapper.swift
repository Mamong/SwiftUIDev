//
//  SFSafariViewWrapper.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import SafariServices
import SwiftUI

struct SFSafariViewWrapper: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<Self>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SFSafariViewWrapper>) {}
}
