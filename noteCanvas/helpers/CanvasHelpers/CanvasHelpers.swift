//
//  CanvasHelpers.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//

import Foundation
import UIKit
func serializePath(_ path: UIBezierPath) -> String {
    return NSKeyedArchiver.archivedData(withRootObject: path).base64EncodedString()
}

func deserializePath(_ serializedPath: String) -> UIBezierPath? {
    guard let data = Data(base64Encoded: serializedPath) else { return nil }
    return NSKeyedUnarchiver.unarchiveObject(with: data) as? UIBezierPath
}
