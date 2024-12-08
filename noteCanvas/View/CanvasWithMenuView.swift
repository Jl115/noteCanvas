////
////  CanvasWithMenuView.swift
////  noteCanvas
////
////  Created by jldev on 08.12.2024.
////
//
//
import SwiftUI

struct CanvasWithMenuView: View {
    @Bindable var note: Note
    @Environment(\.dismiss) private var dismiss // To handle dismissal
    @State private var activeTab: CanvasMenuTab = .shapes

    var body: some View {
        ZStack(alignment: .topLeading) {
            // The main canvas view
            NoteCanvasView(note: note)
                .edgesIgnoringSafeArea(.all)

            // Floating back button
            Button(action: {
                dismiss() // Dismiss the view
            }) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .clipShape(Circle())
                    .shadow(radius: 5)
            }
            .padding(.top, 20)
            .padding(.leading, 20)

            // Floating bottom menu
            GeometryReader { geometry in
                let screenWidth = geometry.size.width
                let screenHeight = geometry.size.height

                HStack {
                    Spacer()

                    MenuButton(tab: .shapes, isActive: activeTab == .shapes) {
                        activeTab = .shapes
                        NoteCanvasView.canvasViewInstance?.switchToMode(.shapes)
                    }

                    Spacer()

                    MenuButton(tab: .drawing, isActive: activeTab == .drawing) {
                        activeTab = .drawing
                        NoteCanvasView.canvasViewInstance?.switchToMode(.drawing)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(12)
                .shadow(radius: 5)
                .frame(width: min(screenWidth - 40, 400)) // Keep the menu responsive
                .position(
                    x: screenWidth / 2, // Center horizontally
                    y: screenHeight - 80 // Fixed gap at the bottom
                )
            }
        }
    }
}

enum CanvasMenuTab: String {
    case shapes = "Shapes"
    case drawing = "Drawing"
}

struct MenuButton: View {
    let tab: CanvasMenuTab
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(tab.rawValue)
                    .fontWeight(.bold)
                    .foregroundColor(isActive ? .blue : .gray)
            }
            .padding()
            .background(isActive ? Color.blue.opacity(0.2) : Color.clear)
            .cornerRadius(8)
        }
    }
}
