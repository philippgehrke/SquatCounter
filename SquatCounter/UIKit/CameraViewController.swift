import Foundation
import UIKit
import AVFoundation
import Vision
import SwiftUI

final class CameraViewController: UIViewController {
    private var cameraSession: AVCaptureSession?
    var delegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    private let cameraQueue = DispatchQueue(
        label: "CameraOutput",
        qos: .userInteractive
    )
    override func loadView() {
        view = CameraView()
    }
    private var cameraView: CameraView { view as! CameraView }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
            if cameraSession == nil {
                try prepareAVSession()
                cameraView.previewLayer.session = cameraSession
                cameraView.previewLayer.videoGravity = .resizeAspectFill
            }
            cameraSession?.startRunning()
        } catch {
            print(error.localizedDescription)
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        cameraSession?.stopRunning()
        super.viewWillDisappear(animated)
    }
    func prepareAVSession() throws {
        let session = AVCaptureSession()
        session.beginConfiguration()
        session.sessionPreset = AVCaptureSession.Preset.high
        
        guard let videoDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera,
                for: .video,
                position: .front)
        else { return }
        
        guard let deviceInput = try? AVCaptureDeviceInput(device: videoDevice)
        else { return }
        
        guard session.canAddInput(deviceInput)
        else { return }
        
        session.addInput(deviceInput)
        
        let dataOutput = AVCaptureVideoDataOutput()
        if session.canAddOutput(dataOutput) {
            session.addOutput(dataOutput)
            dataOutput.setSampleBufferDelegate(delegate, queue: cameraQueue)
        } else { return }
        
        session.commitConfiguration()
        cameraSession = session
    }
}



