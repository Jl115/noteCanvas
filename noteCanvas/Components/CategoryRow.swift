//
//  CategoryRow.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//
import SwiftData
import SwiftUI

struct CategoryRow: View {
    let category: NoteCategory
    @Binding var selecdTag: String?
    var onRename: () -> Void
    var onDelete: () -> Void

    var body: some View {
        Text(category.categoryTitle)
            .tag(category.categoryTitle)
            .styledTag(isSelected: selecdTag == category.categoryTitle)
            .contextMenu {
                Button("Rename", action: onRename)
                Button("Delete", action: onDelete)
            }
    }
}
