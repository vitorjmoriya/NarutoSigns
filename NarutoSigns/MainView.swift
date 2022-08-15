//
//  ContentView.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 04/08/22.
//

import SwiftUI
import AVFoundation

struct MainView: View {
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            CameraPreview(session: viewModel.captureSession)
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

public struct CameraPreview: UIViewRepresentable {
    public class VideoPreviewView: UIView {
        public override class var layerClass: AnyClass {
             return AVCaptureVideoPreviewLayer.self
        }

        var videoPreviewLayer: AVCaptureVideoPreviewLayer {
            return layer as! AVCaptureVideoPreviewLayer
        }
    }

    let session: AVCaptureSession

    public init(session: AVCaptureSession) {
        self.session = session
    }

    public var view: VideoPreviewView = {
        let view = VideoPreviewView()
        view.backgroundColor = .black
        view.videoPreviewLayer.videoGravity = .resizeAspectFill
        return view
    }()

    public func makeUIView(context: Context) -> VideoPreviewView {
        self.view.videoPreviewLayer.session = self.session
        self.view.videoPreviewLayer.connection?.videoOrientation = .landscapeLeft
        return self.view
    }

    public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
}
