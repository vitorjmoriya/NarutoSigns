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
        ZStack(alignment: .center) {
            CameraView(session: viewModel.captureSession)
                .edgesIgnoringSafeArea(.all)

            renderCooldownTimer()

            renderControls()

            VStack {
                Spacer()
                if let sign = viewModel.detectedHandSign, viewModel.cooldownTime == nil {
                    Text(sign.rawValue)
                        .foregroundColor(.white)
                        .font(Font.custom("Ninja-Naruto", size: 60))
                }
            }
        }
    }

    @ViewBuilder private func renderCooldownTimer() -> some View {
        if let cooldownTime = viewModel.cooldownTime {
            Text(String(cooldownTime))
                .foregroundColor(.white)
                .font(Font.custom("Ninja-Naruto", size: 60))
        }
    }

    @ViewBuilder private func renderControls() -> some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {}) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 32, height: 32)
                        .foregroundColor(.orange)
                        .padding(8)
                        .background(.white)
                        .cornerRadius(16)
                }
                .padding(.top, 16)
                .padding(.trailing, 8)
            }
            Spacer()
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var detectedHandSign: Sign? = nil
        @Published var cooldownTime: Int? = nil

        let captureSession: AVCaptureSession

        init(captureSession: AVCaptureSession) {
            self.captureSession = captureSession
        }
    }
}
