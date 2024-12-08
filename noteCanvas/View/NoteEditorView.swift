//
//  NoteEditorView.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//

import SwiftUI

// TODO: Add a clean way to write note this should more look like notion
// TODO: Add the canvas view


struct NoteEditorView: View {
    @Bindable var note: Note
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    @State private var showContextMenu = false
    @State private var cursorPosition: CGPoint = .zero // To track cursor position
    @State private var showCanvasView = false

    var body: some View {
        ZStack {
            // Full-page TextEditor with gesture tracking for cursor position
            TextEditor(text: $note.content)
                .padding()
                .scrollContentBackground(.hidden)
                .multilineTextAlignment(.leading)
                .font(.body)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onTapGesture {
                    withAnimation {
                        showContextMenu = false
                    }
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            cursorPosition = value.location
                        }
                        .onEnded { _ in
                            withAnimation {
                                showContextMenu = true
                            }
                        }
                )

            // Context menu that appears near the cursor
            if showContextMenu {
                VStack {
                    Button(action: { /* Add functionality to create elements */ }) {
                        Text("Add Element")
                    }
                    .padding(8)
                    .background(Color.gray.opacity(0.8))
                    .cornerRadius(8)
                }
                .position(cursorPosition)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    try? context.save()
                    dismiss()
                }
                .foregroundColor(.blue)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showCanvasView.toggle()
                }) {
                    Text("Open Canvas")
                        .foregroundColor(.blue)
                }
            }
        }


            .fullScreenCover(isPresented: $showCanvasView) {
                    CanvasWithMenuView(note: note)
                   }
        
    }
}

