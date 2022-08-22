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

    private var lastTimeSignDetected: Date = .now
    private let intervalBetweenFrames: TimeInterval = 1 // 1 second

    private var cooldownTimer: Timer = .init()
    private var timeElapsed: Int = 0
    private let cooldownTime: Int = 3

    init() {
        self.captureSession = .init()

        let viewModel = MainView.ViewModel(captureSession: self.captureSession)

        let view = MainView(viewModel: viewModel)

        self.viewModel = viewModel

        super.init(rootView: view)

        setupCamera()

        setupManager()

        self.viewModel.state = .cooldown
        self.cooldownTimer = .scheduledTimer(withTimeInterval: 1, repeats: true, block: verifyCooldownTimer)
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

            self.timeElapsed = 0
            self.viewModel.finalHandSign = sign
            self.viewModel.state = .final
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.viewModel.state = .cooldown
                self.cooldownTimer = .scheduledTimer(withTimeInterval: 1, repeats: true, block: self.verifyCooldownTimer)
            }
        }

        self.handSignManager.onHandSign = { [weak self] sign, isStreak in
            guard let self = self else { return }

            self.viewModel.finalHandSign = nil
            self.viewModel.detectedHandSign = sign
            if isStreak {
                self.viewModel.detectedHandSignStreak += 1
            } else {
                self.viewModel.detectedHandSignStreak = 0
            }
            print(sign)
        }
    }

    private func verifyCooldownTimer(timer: Timer) {
        print(timeElapsed)
        guard timeElapsed >= cooldownTime else {
            self.viewModel.detectedHandSign = nil
            timeElapsed += 1
            DispatchQueue.main.async {
                self.viewModel.cooldownTime = self.timeElapsed
            }
            return
        }

        timer.invalidate()
        self.viewModel.detectedHandSignStreak = 0
        self.viewModel.cooldownTime = nil
        self.viewModel.state = .detecting
    }
}

// TODO: Create a separate file with the delegate implementation
extension MainController: AVCaptureVideoDataOutputSampleBufferDelegate {

    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard !cooldownTimer.isValid else {
            return
        }

        let currentDate = Date()
        guard currentDate.timeIntervalSince(lastTimeSignDetected) >= intervalBetweenFrames else {
            return
        }

        lastTimeSignDetected = currentDate

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
