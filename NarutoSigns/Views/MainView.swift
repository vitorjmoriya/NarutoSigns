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

            switch viewModel.state {
            case .initial:
                EmptyView()
            case .error:
                // TODO: handle error here
                EmptyView()
            case .cooldown:
                renderCooldownTimer()
            case .detecting:
                renderDetectingHandSignUI()
            case .final:
                VStack {
                    Spacer()
                    
                    if let sign = viewModel.finalHandSign {
                        Text(sign.rawValue)
                            .foregroundColor(.green)
                            .font(Font.custom("Ninja-Naruto", size: 60))
                    }
                }
            }
        }
    }
    
    @ViewBuilder private func renderDetectingHandSignUI() -> some View {
        VStack {
            HStack(spacing: 20) {
                ForEach(0..<4, id: \.self) { index in
                    Circle()
                        .frame(width: 40, height: 40)
                        .foregroundColor(index < viewModel.detectedHandSignStreak ? .green : .red)
                        .background(
                            Circle()
                                .frame(width: 50, height: 50)
                                .foregroundColor(.black)
                        )
                }
            }
            .padding(.top, 20)
            
            Spacer()
            if let sign = viewModel.detectedHandSign, viewModel.cooldownTime == nil, viewModel.finalHandSign == nil {
                Text(sign.rawValue)
                    .foregroundColor(.white)
                    .font(Font.custom("Ninja-Naruto", size: 60))
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
        @Published var state: State = .initial

        @Published var detectedHandSignStreak: Int = 0
        @Published var detectedHandSign: Sign? = nil
        @Published var finalHandSign: Sign? = nil
        @Published var cooldownTime: Int? = nil

        let captureSession: AVCaptureSession

        init(captureSession: AVCaptureSession) {
            self.captureSession = captureSession
        }
    }
    
    enum State: Equatable {
        case initial
        case error
        case detecting
        case cooldown
        case final
    }
}
