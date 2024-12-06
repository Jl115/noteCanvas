//
//  Item.swift
//  noteCanvas
//
//  Created by jldev on 06.12.2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
