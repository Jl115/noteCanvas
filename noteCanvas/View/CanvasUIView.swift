//
//  CanvasUIView.swift
//  noteCanvas
//
//  Created by jldev on 08.12.2024.
//

import SwiftUI
import UIKit
import SwiftData
import PencilKit

class CanvasUIView: UIView, UITextFieldDelegate, UIPencilInteractionDelegate {
    var note: Note!
    private var scale: CGFloat = 1.0
    private var offset: CGPoint = .zero
    private var drawingPath = UIBezierPath()
    private var isDrawing = false // Whether we're in drawing mode
    private var mode: CanvasMode = .idle // Current interaction mode

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard let context = UIGraphicsGetCurrentContext() else { return }

        // Draw background
        context.setFillColor(UIColor(red: 230 / 255, green: 240 / 255, blue: 1, alpha: 1.0).cgColor)
        context.fill(rect)

        // Draw grid
        drawDots(in: context, rect: rect)

        // Draw canvas objects
        for object in note.objects {
            drawCanvasObject(object, in: context)
        }

        // Draw freeform drawing
        if mode == .drawing {
            context.saveGState()
            context.translateBy(x: offset.x, y: offset.y) // Apply offset
            context.scaleBy(x: scale, y: scale) // Apply scale

            UIColor.black.setStroke()
            drawingPath.lineWidth = 2.0 / scale // Adjust line width for scale
            drawingPath.stroke()

            context.restoreGState()
        }
    }



    func drawDots(in context: CGContext, rect: CGRect) {
        let gridSize: CGFloat = 50 * scale
        let dotRadius: CGFloat = 2.0 / scale // Scale dot size to match zoom level

        context.setFillColor(UIColor.lightGray.withAlphaComponent(0.5).cgColor)

        for x in stride(from: offset.x.truncatingRemainder(dividingBy: gridSize), to: rect.width, by: gridSize) {
            for y in stride(from: offset.y.truncatingRemainder(dividingBy: gridSize), to: rect.height, by: gridSize) {
                let dotCenter = CGPoint(x: x, y: y)
                let dotRect = CGRect(
                    x: dotCenter.x - dotRadius,
                    y: dotCenter.y - dotRadius,
                    width: dotRadius * 2,
                    height: dotRadius * 2
                )
                context.fillEllipse(in: dotRect)
            }
        }
    }


    func drawCanvasObject(_ object: CanvasObject, in context: CGContext) {
        let position = CGPoint(
            x: (object.position.x * scale) + offset.x,
            y: (object.position.y * scale) + offset.y
        )
        let size = CGSize(width: object.size.width * scale, height: object.size.height * scale)

        if object.type == .rectangle {
            context.setFillColor(UIColor.blue.cgColor)
            context.fill(CGRect(origin: position, size: size))
        } else if object.type == .circle {
            context.setFillColor(UIColor.red.cgColor)
            context.fillEllipse(in: CGRect(origin: position, size: size))
        } else if object.type == .text {
            let text = object.content ?? "New Text"
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16 * scale),
                .foregroundColor: UIColor.black
            ]
            let textSize = text.size(withAttributes: attributes)
            let textRect = CGRect(origin: CGPoint(x: position.x, y: position.y - textSize.height / 2), size: textSize)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }

    func setupGestureRecognizers() {
        // Pan gesture for panning the canvas (two fingers)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        panGesture.minimumNumberOfTouches = 2 // Restrict to two fingers for dragging
        self.addGestureRecognizer(panGesture)

        // Pinch gesture for zooming the canvas
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        self.addGestureRecognizer(pinchGesture)

        // Tap gesture for adding shapes
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)

        // Pencil interaction for toggling modes
        let pencilInteraction = UIPencilInteraction()
        pencilInteraction.delegate = self
        self.addInteraction(pencilInteraction)
    }

    @objc func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)

        if mode == .drawing {
            // Convert touch location to canvas-relative coordinates
            let relativeLocation = CGPoint(
                x: (location.x - offset.x) / scale,
                y: (location.y - offset.y) / scale
            )

            if gesture.state == .began {
                drawingPath.move(to: relativeLocation)
            } else if gesture.state == .changed {
                drawingPath.addLine(to: relativeLocation)
            } else if gesture.state == .ended {
                // Save the drawing as a CanvasObject for persistence
                let pathBounds = drawingPath.bounds
                let drawingObject = CanvasObject(
                    type: .path,
                    position: CGPoint(x: pathBounds.origin.x, y: pathBounds.origin.y),
                    size: CGSize(width: pathBounds.width, height: pathBounds.height),
                    content: nil // Optional: Add serialized path data if needed
                )
                note.objects.append(drawingObject)
//                drawingPath.removeAllPoints() // Clear the path
            }
            setNeedsDisplay()
        } else {
            // Handle panning for the canvas
            if gesture.state == .changed {
                let translation = gesture.translation(in: self)
                offset = CGPoint(x: offset.x + translation.x, y: offset.y + translation.y)
                gesture.setTranslation(.zero, in: self)
                setNeedsDisplay()
            }
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return } // Restrict to Apple Pencil

        let location = touch.preciseLocation(in: self)
        let relativeLocation = CGPoint(
            x: (location.x - offset.x) / scale,
            y: (location.y - offset.y) / scale
        )
        drawingPath.move(to: relativeLocation)
        setNeedsDisplay()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return } // Restrict to Apple Pencil

        let location = touch.preciseLocation(in: self)
        let relativeLocation = CGPoint(
            x: (location.x - offset.x) / scale,
            y: (location.y - offset.y) / scale
        )
        drawingPath.addLine(to: relativeLocation)
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, touch.type == .pencil else { return } // Restrict to Apple Pencil

        // Save the drawing as a CanvasObject
        let pathBounds = drawingPath.bounds
        let drawingObject = CanvasObject(
            type: .path,
            position: CGPoint(x: pathBounds.origin.x, y: pathBounds.origin.y),
            size: CGSize(width: pathBounds.width, height: pathBounds.height),
            content: serializePath(drawingPath) // Serialize path for persistence
        )
        note.objects.append(drawingObject)

        setNeedsDisplay()
    }




    @objc func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        scale = max(0.5, min(scale * gesture.scale, 5.0)) // Clamp scale
        gesture.scale = 1.0
        setNeedsDisplay()
    }

    @objc func handleTapGesture(_ gesture: UITapGestureRecognizer) {
        let tapLocation = gesture.location(in: self)

        if mode == .shapes {
            // Alternate between rectangle and circle
            let isCircle = note.objects.count % 2 == 0 // Example condition
            let newObject = CanvasObject(
                type: isCircle ? .circle : .rectangle,
                position: CGPoint(
                    x: (tapLocation.x - offset.x) / scale,
                    y: (tapLocation.y - offset.y) / scale
                ),
                size: isCircle ? CGSize(width: 80, height: 80) : CGSize(width: 100, height: 50)
            )
            note.objects.append(newObject)
            setNeedsDisplay()
        }
    }


    func switchToMode(_ newMode: CanvasMode) {
        mode = newMode
        setNeedsDisplay()
    }


    
}


// MARK: - Interaction Modes
enum CanvasMode {
    case idle
    case drawing
    case shapes
}
