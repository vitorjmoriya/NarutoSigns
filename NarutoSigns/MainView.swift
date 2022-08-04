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
//                .onAppear {
//                    viewModel.captureSession.startRunning()
//                }
//                .onDisappear {
//                    viewModel.captureSession.stopRunning()
//                }
                .edgesIgnoringSafeArea(.all)
            VStack(alignment: .leading) {
                Button(action:  {print("Tapped") } ) {
                    Text("TAP ME")
                        .foregroundColor(.red)
                }
            }
        }
    }
}

extension MainView {
    class ViewModel: ObservableObject {
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
        return self.view
    }

    public func updateUIView(_ uiView: VideoPreviewView, context: Context) { }
}
