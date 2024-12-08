//
//  Category.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//

import SwiftData
import SwiftUI

@Model
class NoteCategory {
    var categoryTitle: String

    @Relationship(deleteRule: .cascade, inverse: \Note.noteCategory)
    var notes: [Note]?

    init(categoryTitle: String) {
        self.categoryTitle = categoryTitle
    }
}
