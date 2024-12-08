//
//  CanvasObject.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//


import SwiftData
import SwiftUI

@Model
class CanvasObject {
    var id: UUID
    var type: CanvasObjectType
    var positionX: Double // Use `Double` for persistence compatibility
    var positionY: Double
    var sizeWidth: Double
    var sizeHeight: Double
    var content: String? // Optional content for text objects

    init(type: CanvasObjectType, position: CGPoint, size: CGSize, content: String? = nil) {
        self.id = UUID()
        self.type = type
        self.positionX = position.x
        self.positionY = position.y
        self.sizeWidth = size.width
        self.sizeHeight = size.height
        self.content = content
    }

    // Convenience computed properties for position and size
    var position: CGPoint {
        get { CGPoint(x: positionX, y: positionY) }
        set {
            positionX = newValue.x
            positionY = newValue.y
        }
    }

    var size: CGSize {
        get { CGSize(width: sizeWidth, height: sizeHeight) }
        set {
            sizeWidth = newValue.width
            sizeHeight = newValue.height
        }
    }
}

// Enum for the object type (not persistent, so no @Model here)
enum CanvasObjectType: String, Codable {
    case rectangle
    case circle
    case text
    case path // New type for drawn shapes
}
