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
        // create the request
        let request = VNDetectRectanglesRequest(completionHandler: handleVisionRequestUpdate)
        request.minimumConfidence = 0.7
        request.minimumSize = 0.5
        //request.quadratureTolerance = 10

        // perform the request
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
            self.onRectDetect?(transformedRect)
        }
    }
}
