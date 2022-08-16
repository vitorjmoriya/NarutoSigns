//
//  ContentView.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 04/08/22.
//

import AVFoundation
import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            CameraView(session: viewModel.captureSession)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text(viewModel.detectedHandSign)
                    .foregroundColor(.white)
                    .font(.system(size: 50))
            }
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var detectedHandSign: String = ""

        let captureSession: AVCaptureSession

        init(captureSession: AVCaptureSession) {
            self.captureSession = captureSession
        }
    }
}
