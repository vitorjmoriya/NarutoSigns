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
                Spacer()
                Text(viewModel.detectedHandSign)
                    .foregroundColor(.white)
                    .font(Font.custom("Ninja-Naruto", size: 60))
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
