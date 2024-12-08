//
//  TextEditorWithCursorTracking.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//


import SwiftUI

struct TextEditorWithCursorTracking: UIViewRepresentable {
    @Binding var text: String
    @Binding var cursorFrame: CGRect

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isScrollEnabled = true
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.delegate = context.coordinator
        context.coordinator.textView = textView
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
        context.coordinator.cursorFrameBinding = $cursorFrame
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: TextEditorWithCursorTracking
        var textView: UITextView?
        var cursorFrameBinding: Binding<CGRect>?

        init(_ parent: TextEditorWithCursorTracking) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            DispatchQueue.main.async {
                self.parent.text = textView.text
                if let selectedRange = textView.selectedTextRange {
                    // Directly get the caret rect for the current cursor position
                    let cursorFrame = textView.caretRect(for: selectedRange.start)
                    self.cursorFrameBinding?.wrappedValue = textView.convert(cursorFrame, to: nil)
                }
            }
        }
    }
}
