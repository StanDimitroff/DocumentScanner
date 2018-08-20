//
//  RectangleDetector.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import Vision

@available (iOS 11.0, *)
final class RectangleDetector {

    var onRectDetect: ((ObservationRectangle, CGRect) -> Void)?
    private let visionSequenceHandler = VNSequenceRequestHandler()

    var minimumConfidence: Float = 0.0
    var minimumSize: Float = 0.2
    var quadratureTolerance: Float = 30
    var minimumAspectRatio: Float = 0.5
    var maximumAspectRatio: Float = 1

    @discardableResult
    func config(_ block: (RectangleDetector) throws -> Void) rethrows -> Self {
        try block(self)
        
        return self
    }

    func detect(from pixelBuffer: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest(completionHandler: handleVisionRequestUpdate)
        
        request.minimumConfidence   = minimumConfidence
        request.minimumSize         = minimumSize
        request.quadratureTolerance = quadratureTolerance
        request.minimumAspectRatio  = minimumAspectRatio
        request.maximumAspectRatio  = maximumAspectRatio

        request.preferBackgroundProcessing = true

        let exifOrientation = Utils.exifOrientationFromDeviceOrientation()

        do {
            try visionSequenceHandler.perform([request], on: pixelBuffer, orientation: exifOrientation)
        } catch {
            print("Throws: \(error)")
        }
    }

    private func handleVisionRequestUpdate(_ request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            // make sure we have an actual result
            guard let newObservation = request.results?.first as? VNRectangleObservation
                else { self.onRectDetect?(.zero, .zero); return }

            let transformedRect = newObservation.boundingBox

            var observationRect = ObservationRectangle()
            observationRect.topLeft     = newObservation.topLeft
            observationRect.topRight    = newObservation.topRight
            observationRect.bottomRight = newObservation.bottomRight
            observationRect.bottomLeft  = newObservation.bottomLeft

            if transformedRect.isEmpty { return }

            self.onRectDetect?(observationRect, transformedRect)
        }
    }
}
