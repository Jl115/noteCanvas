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
    var objects: [CanvasObject] // Persistent relationship
    var noteCategory: NoteCategory?
    var isFavorite: Bool = false

    init(content: String, objects: [CanvasObject] = [], noteCategory: NoteCategory? = nil) {
        self.content = content
        self.objects = objects
        self.noteCategory = noteCategory
    }
}


