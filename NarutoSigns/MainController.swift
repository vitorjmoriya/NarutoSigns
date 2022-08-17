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

    private let handSignManager: HandsignManager = HandsignManager.shared

    var lastSampleDate = Date.distantPast
    let sampleInterval: TimeInterval = 1 // 1 second

    init() {
        self.captureSession = .init()

        let viewModel = MainView.ViewModel(captureSession: self.captureSession)

        let view = MainView(viewModel: viewModel)

        self.viewModel = viewModel

        super.init(rootView: view)

        setupCamera()

        setupManager()
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
            // TODO: Handle error in UI
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

    private func setupManager() {
        self.handSignManager.onDetectedHandSign = { [weak self] sign in
            guard let self = self else { return }

            self.viewModel.detectedHandSign = sign
        }
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

        let handler = VNImageRequestHandler(cmSampleBuffer: sampleBuffer)

        do {
            try handler.perform([handPoseRequest])
            guard let observation = handPoseRequest.results?.first else {
                setSign(from: nil)
                return
            }

            guard let array = try? observation.keypointsMultiArray() else {
                return
            }

            let input: NarutoSignsInput = .init(poses: array)

            let handPosePrediction = try HandsignModel.shared.model.prediction(input: input)

            setSign(from: handPosePrediction)
        } catch {
            print(error)
        }
    }

    private func setSign(from sign: NarutoSignsOutput?) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }

            guard
                let sign = sign
            else {
                self.viewModel.detectedHandSign = nil
                return
            }

            self.handSignManager.addHandSign(sign: sign)
        }
    }
}
