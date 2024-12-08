//
//  NoteCanvasView.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//


import SwiftUI
import SwiftData

struct NoteCanvasView: UIViewRepresentable {
    @Bindable var note: Note
    static var canvasViewInstance: CanvasUIView?

    func makeUIView(context: Context) -> CanvasUIView {
        let canvasView = CanvasUIView()
        canvasView.note = note
        canvasView.setupGestureRecognizers()
        NoteCanvasView.canvasViewInstance = canvasView // Store instance
        return canvasView
    }

    func updateUIView(_ uiView: CanvasUIView, context: Context) {
        uiView.note = note
        uiView.setNeedsDisplay()
    }
}

 
