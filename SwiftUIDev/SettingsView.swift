//
//  SettingsView.swift
//  SwiftUIDev
//
//  Created by tryao on 9/14/24.
//

import StoreKit
import SwiftUI

struct SettingsView: View {
    @AppStorage("appearance") var appearance: AppearanceMode = .system

    @AppStorage("showUpdate") var showUpdate = true

    @Environment(\.requestReview) private var requestReview

    @State private var showPopover = false

    private let url = URL(string: "https://www.appcoda.com")!

    var body: some View {
        NavigationStack {
            Form {
                Section("Settings") {
                    Picker("Appearance", selection: $appearance) {
                        Text("system").tag(AppearanceMode.system)
                        Text("light").tag(AppearanceMode.light)
                        Text("dark").tag(AppearanceMode.dark)
                    }
                    Toggle(isOn: $showUpdate) {
                        Button {
                            showPopover = true
                        } label: {
                            HStack {
                                Text("Article/sample status").foregroundColor(.primary)
                                Image(systemName: "questionmark.circle")
                            }
                        }
                    }.popover(isPresented: $showPopover) {
                        UpdateStatusView(onTapDone: {
                            showPopover = false
                        }).preferredColorScheme(appearance.colorScheme)
                    }
                }

                Section("Support") {
                    ShareLink(item: url, subject: Text("Check out this link"), message: Text("If you want to learn Swift, take a look at this website.")) {
                        HStack {
                            Text("Share").foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    Button {
                        requestReview()
                    } label: {
                        HStack {
                            Text("Review").foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "square.and.pencil")
                        }
                    }

                    Link(destination: URL(string: "https://www.producthunt.com")!) {
                        HStack {
                            Text("Vote").foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "hand.thumbsup")
                        }
                    }
                }
                Section("Contact") {
                    Link(destination: URL(string: "https://www.x.com")!) {
                        HStack {
                            ///如果直接使用Image，则分割线从Spacer后面的Text开始
                            Text("\(Image("x_logo"))")
                            Spacer()
                            Text("@swiftuidev")
                        }
                    }
                    Link(destination: URL(string: "tg://resolve?domain=swiftuidev")!) {
                        HStack {
                            Text("\(Image(systemName: "paperplane"))").foregroundColor(.primary)
                            Spacer()
                            Text("Telegram")
                        }
                    }
                    Link(destination: URL(string: "mailto:swiftuidev@gmail.com")!) {
                        HStack {
                            Image(systemName: "envelope").foregroundColor(.primary)
                            Spacer()
                            Text("swiftuidev@gmail.com")
                        }
                    }
                }
                Section("Version Info") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("2.5.2")
                    }

                    NavigationLink {
                        Text("unavailable").toolbar(.hidden, for: .tabBar)
                    } label: {
                        Text("Update log")
                    }
                }

                Section {
                    Button("Recover purchase") {}
                } footer: {
                    Text("Tips: all sample codes could be copied, preview and run in Xcode, which are the same as the source code of the samples.")
                }
            }.navigationTitle("Settings")
        }
    }
}

struct UpdateStatusView: View {
    var onTapDone: ()->Void

    var body: some View{
        NavigationStack {
            Form {
                Section {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.background, .green)
                        Text("Add")
                    }
                    HStack {
                        Image(systemName: "circle.fill")
                            .foregroundColor(.purple)
                            .overlay {
                                Image(systemName: "alternatingcurrent")
                                    .foregroundStyle(.background)
                                    .scaleEffect(0.5)
                            }
                        Text("Alter")
                    }
                } header: {
                    Text("Status badge")
                } footer: {
                    Text("Only show update status between recently two version")
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Done", action: onTapDone)
                }
            }
            .navigationTitle("Update status description")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
