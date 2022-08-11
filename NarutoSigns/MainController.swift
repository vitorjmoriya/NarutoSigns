//
//  MainController.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 04/08/22.
//

import SwiftUI
import AVFoundation
import CoreML
import Vision

class MainController: UIHostingController<MainView> {
    private let captureSession: AVCaptureSession

    private let viewModel: MainView.ViewModel

    var lastSampleDate = Date.distantPast
    let sampleInterval: TimeInterval = 2 // 5 seconds

    init() {
        self.captureSession = .init()

        let viewModel = MainView.ViewModel(captureSession: self.captureSession)

        let view = MainView(viewModel: viewModel)

        self.viewModel = viewModel

        super.init(rootView: view)

        setupCamera()
    }

    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .front
        ) else {
            print("## No frontal camera found")
            return
        }
        guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice),
              self.captureSession.canAddInput(captureDeviceInput)
        else {
            return
        }

        self.captureSession.addInput(captureDeviceInput)

        let bufferQueue = DispatchQueue(label: "bufferRate", qos: .userInteractive, attributes: .concurrent)
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: bufferQueue)
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        self.captureSession.startRunning()
    }
}

extension MainController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentDate = Date()
        guard currentDate.timeIntervalSince(lastSampleDate) >= sampleInterval else {
            return
        }

        lastSampleDate = currentDate

        let handPoseRequest: VNDetectHumanHandPoseRequest = .init()

        handPoseRequest.maximumHandCount = 1

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer, orientation: .up, options: [:])
        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                return
            }

            guard let array = try? observation.keypointsMultiArray() else {
                return
            }

            let handSignClassifier: NarutoSigns = try NarutoSigns(configuration: .init())

            let input: NarutoSignsInput = .init(poses: array)

            let handPosePrediction = try handSignClassifier.prediction(input: input)

            print(handPosePrediction.labelProbabilities)

            DispatchQueue.main.async {
                self.viewModel.label = handPosePrediction.label
            }
        } catch {
            print(error)
        }
    }
}
