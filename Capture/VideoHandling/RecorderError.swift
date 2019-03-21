import Foundation

public enum RecorderError: String, Error {
    case invalidDisplay = "The display id passed in is invalid"
    case invalidAudioDevice = "The audio device is invalid"
    case couldNotAddScreen = "Could not add screen to input"
    case couldNotAddMic = "Could not mic to input"
    case couldNotAddOutput = "Could not add output"
}
