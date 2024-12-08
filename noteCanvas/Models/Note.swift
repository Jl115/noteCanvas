//
//  Note.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//

import SwiftData
import SwiftUI

@Model
class Note {
    var content: String
    var noteCategory: NoteCategory?
    var isFavorite: Bool = false

    init(content: String, noteCategory: NoteCategory? = nil) {
        self.content = content
        self.noteCategory = noteCategory
        isFavorite = isFavorite
    }
}
