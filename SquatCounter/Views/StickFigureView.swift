import SwiftUI

struct StickFigureView: View {
    @ObservedObject var poseEstimator: PoseEstimator
    var size: CGSize
    var body: some View {
        if poseEstimator.bodyParts.isEmpty == false {
            ZStack {
                // Right leg
                Stick(points: [poseEstimator.bodyParts[.rightAnkle]!.location, poseEstimator.bodyParts[.rightKnee]!.location, poseEstimator.bodyParts[.rightHip]!.location,
                poseEstimator.bodyParts[.root]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Left leg
                Stick(points: [poseEstimator.bodyParts[.leftAnkle]!.location, poseEstimator.bodyParts[.leftKnee]!.location, poseEstimator.bodyParts[.leftHip]!.location,
                               poseEstimator.bodyParts[.root]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Right arm
                Stick(points: [poseEstimator.bodyParts[.rightWrist]!.location, poseEstimator.bodyParts[.rightElbow]!.location, poseEstimator.bodyParts[.rightShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Left arm
                Stick(points: [poseEstimator.bodyParts[.leftWrist]!.location, poseEstimator.bodyParts[.leftElbow]!.location, poseEstimator.bodyParts[.leftShoulder]!.location, poseEstimator.bodyParts[.neck]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)
                // Root to nose
                Stick(points: [poseEstimator.bodyParts[.root]!.location,
                               poseEstimator.bodyParts[.neck]!.location,  poseEstimator.bodyParts[.nose]!.location], size: size)
                    .stroke(lineWidth: 5.0)
                    .fill(Color.green)

                }
            }
        }
}

