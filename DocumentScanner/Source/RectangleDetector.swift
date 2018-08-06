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

    func detect(from pixelBuffer: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest(completionHandler: handleVisionRequestUpdate)
        request.minimumConfidence   = 0.6
        request.minimumSize         = 0.3
        request.quadratureTolerance = 45
        request.preferBackgroundProcessing = true

        do {
            try visionSequenceHandler.perform([request], on: pixelBuffer)
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
