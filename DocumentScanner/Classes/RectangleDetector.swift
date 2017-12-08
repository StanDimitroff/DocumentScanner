//
//  RectangleDetector.swift
//  DocumentScanner
//
//  Created by Stanislav Dimitrov on 20.11.17.
//

import Foundation
import Vision

final class RectangleDetector {

    var onRectDetect: ((CGRect) -> Void)?
    private let visionSequenceHandler = VNSequenceRequestHandler()

    func detect(on pixelBuffer: CVPixelBuffer) {
        let request = VNDetectRectanglesRequest(completionHandler: handleVisionRequestUpdate)
        request.minimumConfidence = 0.6
        request.minimumSize = 0.3
        request.quadratureTolerance = 45

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
                else { self.onRectDetect?(.zero); return }

            let transformedRect = newObservation.boundingBox

            if transformedRect.isEmpty { return }
            
            self.onRectDetect?(transformedRect)
        }
    }
}
