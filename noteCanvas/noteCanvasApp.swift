//
//  noteCanvasApp.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//

import SwiftData
import SwiftUI

@main
struct noteCanvasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 400, minHeight: 400)
        }
        .windowResizability(.contentSize)
        .modelContainer(for: [Note.self, NoteCategory.self])
    }
}
