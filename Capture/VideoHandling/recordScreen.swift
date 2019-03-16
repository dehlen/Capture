import Foundation
import AVFoundation

public func recordScreen(destination: URL, displayId: CGDirectDisplayID, cropRect: CGRect?, audioDevice: AVCaptureDevice?) throws -> Recorder {
    return try Recorder.init(destination: destination, displayId: displayId, cropRect: cropRect, audioDevice: audioDevice)
}

public func recordScreen(destination: URL) throws -> Recorder {
    return try Recorder.init(destination: destination, displayId: CGMainDisplayID(), cropRect: nil, audioDevice: nil)
}
