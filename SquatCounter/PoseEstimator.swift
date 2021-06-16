import Foundation
import AVFoundation
import Vision
import Combine

class PoseEstimator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    let sequenceHandler = VNSequenceRequestHandler()    
    @Published var bodyParts = [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]()
    var wasInBottomPosition = false
    @Published var squatCount = 0
    @Published var isGoodPosture = true
    
    var subscriptions = Set<AnyCancellable>()
    
    override init() {
        super.init()
        $bodyParts
            .dropFirst()
            .sink(receiveValue: { bodyParts in self.countSquats(bodyParts: bodyParts)})
            .store(in: &subscriptions)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let humanBodyRequest = VNDetectHumanBodyPoseRequest(completionHandler: detectedBodyPose)
        do {
            try sequenceHandler.perform(
              [humanBodyRequest],
              on: sampleBuffer,
                orientation: .right)
        } catch {
          print(error.localizedDescription)
        }
    }
    func detectedBodyPose(request: VNRequest, error: Error?) {
        guard let bodyPoseResults = request.results as? [VNHumanBodyPoseObservation]
          else { return }
        guard let bodyParts = try? bodyPoseResults.first?.recognizedPoints(.all) else { return }
        DispatchQueue.main.async {
            self.bodyParts = bodyParts
        }
    }
    
    func countSquats(bodyParts: [VNHumanBodyPoseObservation.JointName : VNRecognizedPoint]) {
        
        let rightKnee = bodyParts[.rightKnee]!.location
        let leftKnee = bodyParts[.rightKnee]!.location
        let rightHip = bodyParts[.rightHip]!.location
        let rightAnkle = bodyParts[.rightAnkle]!.location
        let leftAnkle = bodyParts[.leftAnkle]!.location
        
        let firstAngle = atan2(rightHip.y - rightKnee.y, rightHip.x - rightKnee.x)
        let secondAngle = atan2(rightAnkle.y - rightKnee.y, rightAnkle.x - rightKnee.x)
        var angleDiffRadians = firstAngle - secondAngle
        while angleDiffRadians < 0 {
                    angleDiffRadians += CGFloat(2 * Double.pi)
                }
        let angleDiffDegrees = Int(angleDiffRadians * 180 / .pi)
        if angleDiffDegrees > 150 && self.wasInBottomPosition {
            self.squatCount += 1
            self.wasInBottomPosition = false
        }
        
        let hipHeight = rightHip.y
        let kneeHeight = rightKnee.y
        if hipHeight < kneeHeight {
            self.wasInBottomPosition = true
        }
        

        let kneeDistance = rightKnee.distance(to: leftKnee)
        let ankleDistance = rightAnkle.distance(to: leftAnkle)
        
        if ankleDistance > kneeDistance {
            self.isGoodPosture = false
        } else {
            self.isGoodPosture = true
        }
        
    }

}
