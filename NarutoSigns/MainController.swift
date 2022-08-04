//
//  MainController.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 04/08/22.
//

import SwiftUI
import AVFoundation

class MainController: UIHostingController<MainView> {
    private let captureSession: AVCaptureSession

    init() {
        self.captureSession = .init()

        let view = MainView(viewModel: .init(captureSession: self.captureSession))

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

        self.captureSession.startRunning()
    }
}
