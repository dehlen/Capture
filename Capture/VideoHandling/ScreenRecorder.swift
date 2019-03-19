import AVFoundation
import os

public class Recorder: NSObject {
    let session: AVCaptureSession
    private let destination: URL
    private let output: AVCaptureMovieFileOutput

    public init(destination: URL, displayId: CGDirectDisplayID, cropRect: CGRect?, audioDevice: AVCaptureDevice?) throws {
        self.destination = destination
        session = AVCaptureSession()

        guard let input = AVCaptureScreenInput.init(displayID: displayId) else {
            throw RecorderError.invalidDisplay
        }

        // input.minFrameDuration = CMTimeMake(1, Int32(fps))

        if let cropRect = cropRect {
            input.cropRect = cropRect
        }

        input.capturesCursor = Current.defaults[.showMouseCursor] ?? true
        input.capturesMouseClicks = Current.defaults[.showMouseClicks] ?? true

        output = AVCaptureMovieFileOutput()
        output.movieFragmentInterval = CMTime.invalid

        if let audioDevice = audioDevice {
            if !audioDevice.hasMediaType(AVMediaType.audio) {
                os_log(.error, log: .videoRecorder, "Invalid Audio Device")
                throw RecorderError.invalidAudioDevice
            }

            let audioInput = try AVCaptureDeviceInput(device: audioDevice)

            if session.canAddInput(audioInput) {
                session.addInput(audioInput)
            } else {
                os_log(.error, log: .videoRecorder, "Could not add microphone")
                throw RecorderError.couldNotAddMic
            }
        }

        if session.canAddInput(input) {
            session.addInput(input)
        } else {
            os_log(.error, log: .videoRecorder, "Could not add screen")
            throw RecorderError.couldNotAddScreen
        }

        if session.canAddOutput(output) {
            session.addOutput(output)
        } else {
            os_log(.error, log: .videoRecorder, "Could not add output")
            throw RecorderError.couldNotAddOutput
        }
    }

    public func start() {
        session.startRunning()
        output.startRecording(to: destination, recordingDelegate: self)
    }

    public func pause() {
        output.pauseRecording()
    }

    public func resume() {
        output.resumeRecording()
    }

    public func stop() {
        output.stopRecording()
        session.stopRunning()
    }
}

extension Recorder: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput,
                           didFinishRecordingTo outputFileURL: URL,
                           from connections: [AVCaptureConnection],
                           error: Error?) {
        print(error)
    }

    public func capture(_ captureOutput: AVCaptureFileOutput!,
                        didStartRecordingToOutputFileAt fileURL: URL!,
                        fromConnections connections: [Any]!) {
    }

    public func capture(_ captureOutput: AVCaptureFileOutput!,
                        didFinishRecordingToOutputFileAt outputFileURL: URL!,
                        fromConnections connections: [Any]!,
                        error: Error!) {
        print(error)
    }
}
