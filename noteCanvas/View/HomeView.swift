//
//  HomeView.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//

import SwiftData
import SwiftUI

struct HomeView: View {
    @State private var selecdTag: String?
    @Query(animation: .snappy) private var noteCategories: [NoteCategory]

    @State private var addCategory: Bool = false
    @State private var categoryTitle: String = ""
    @State private var requestedCategory: NoteCategory?
    @State private var deleteRequest: Bool = false
    @State private var renameRequest: Bool = false
    @State private var isDarkMode: Bool = true

    @Environment(\.modelContext) private var context

    var body: some View {
        NavigationSplitView {
            categoryList
        } detail: {

            NotesView(category: selecdTag)
                .navigationTitle(selecdTag ?? "Note Canvas")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        HStack(spacing: 10) {
                            Button("", systemImage: "plus") {
                                let note = Note(content: "")
                                context.insert(note)
                            }
                            Button("", systemImage: isDarkMode ? "sun.min" : "moon") {
                                isDarkMode.toggle()
                            }
                        }
                    }
                }
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .alert("Add Category", isPresented: $addCategory) {
            TextField("Category Title", text: $categoryTitle)
            Button("Add", action: addNewCategory)
            Button("Cancel", role: .cancel, action: resetCategoryState)
        }
        .alert("Delete Category", isPresented: $deleteRequest) {
            Button("Delete", role: .destructive, action: deleteCategory)
            Button("Cancel", role: .cancel, action: resetCategoryState)
        }
        .alert("Rename Category", isPresented: $renameRequest) {
            TextField("Category Title", text: $categoryTitle)
            Button("Rename", action: renameCategory)
            Button("Cancel", role: .cancel, action: resetCategoryState)
        }
    }

    // MARK: - Components

    private var categoryList: some View {
        List(selection: $selecdTag) {
            predefinedTagsSection
            categoriesSection
        }
    }

    private var predefinedTagsSection: some View {
        Group {
            Text("All Notes")
                .tag("All Notes")
                .styledTag(isSelected: selecdTag == "All Notes")
            Text("Favorites")
                .tag("Favorites")
                .styledTag(isSelected: selecdTag == "Favorites")
        }
    }

    private var categoriesSection: some View {
        Section {
            ForEach(noteCategories) { category in
                CategoryRow(
                    category: category,
                    selecdTag: $selecdTag,
                    onRename: {
                        categoryTitle = category.categoryTitle
                        requestedCategory = category
                        renameRequest.toggle()
                    },
                    onDelete: {
                        requestedCategory = category
                        deleteRequest.toggle()
                    }
                )
            }
        } header: {
            HStack(spacing: 10) {
                Text("Categories")
                Button(action: { addCategory.toggle() }) {
                    Image(systemName: "plus")
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Functions

    private func addNewCategory() {
        let newCategory = NoteCategory(categoryTitle: categoryTitle)
        context.insert(newCategory)
        resetCategoryState()
    }

    private func deleteCategory() {
        if let requestedCategory = requestedCategory {
            context.delete(requestedCategory)
        }
        resetCategoryState()
    }

    private func renameCategory() {
        if let requestedCategory = requestedCategory {
            requestedCategory.categoryTitle = categoryTitle
        }
        resetCategoryState()
    }

    private func resetCategoryState() {
        categoryTitle = ""
        requestedCategory = nil
    }
}

// MARK: - Extensions

extension View {
    func styledTag(isSelected: Bool) -> some View {
        foregroundStyle(isSelected ? Color.primary : .purple)
    }
}
