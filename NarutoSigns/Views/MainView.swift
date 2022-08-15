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
                HStack(spacing: 10) {
                    ForEach(viewModel.gestures, id: \.self) { gesture in
                        Text(gesture)
                            .foregroundColor(.white)
                            .font(.system(size: 50))
                    }
                }
                .padding(.bottom, 10)
                .padding(.leading, 10)
            }
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
        @Published var gestures: [String] = []
        let captureSession: AVCaptureSession

        init(captureSession: AVCaptureSession) {
            self.captureSession = captureSession
        }
    }
}
