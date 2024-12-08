//
//  NotesView.swift
//  noteCanvas
//
//  Created by jldev on 07.12.2024.
//

import SwiftData
import SwiftUI

struct NotesView: View {
    var category: String?

    @Environment(\.modelContext) private var context

    @Query private var notes: [Note]
    init(category: String?) {
        self.category = category

        let predicate = #Predicate<Note> { note in
            return note.noteCategory?.categoryTitle == category
        }

        let favoritePredicate = #Predicate<Note> { note in
            return note.isFavorite
        }

        let finalPredicate = category == "All Notes" ? nil : (category == "Favorite Notes" ? favoritePredicate : predicate)

        _notes = Query(filter: finalPredicate, sort: [], animation: .snappy)
    }

    @FocusState private var isKeyboard: Bool
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let size = geometry.size
                let width = size.width

                let rowCount = max(Int(width / 250), 1)

                ScrollView(.vertical) {
                    LazyVGrid(
                        columns: Array(repeating: GridItem(spacing: 10), count: rowCount), spacing: 10
                    ) {
                        ForEach(notes) { note in
                            NavigationLink(destination: NoteEditorView(note: note)) {
                                noteCardView(note: note, isKeyboardEnabled: $isKeyboard)
                                    .contextMenu {
                                        Button("Delete note") {
                                            context.delete(note)
                                            print("Deleted note: \(note)")
                                        }
                                    }
                            }
                        }
                    }
                    .padding(12)
                }
                .onTapGesture {
                    isKeyboard = false
                }
            }
        }
    }
}


struct noteCardView: View {
    @Bindable var note: Note
    var isKeyboardEnabled: FocusState<Bool>.Binding
    var body: some View {
        TextEditor(text: $note.content)
            .focused(isKeyboardEnabled)
            .overlay(alignment: .leading, content: {
                Text("Finish Work ")
                    .foregroundStyle(.gray)
                    .padding(.leading, 5)
                    .opacity(note.content.isEmpty ? 1 : 0)
                    .allowsTightening(false)
            })
            .padding(15)
            .scrollContentBackground(.hidden)
            .multilineTextAlignment(.leading)
            .kerning(1)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(.gray.opacity(0.15), in: .rect(cornerRadius: 12))
    }
}

#Preview {
    ContentView()
}
