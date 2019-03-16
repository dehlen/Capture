import Foundation

extension NSNotification.Name {
    static let shouldStopRecording = NSNotification.Name("on-should-stop-recording")
    static let shouldStartRecording = NSNotification.Name("on-should-start-recording")
    static let shouldStopSelection = NSNotification.Name("on-should-stop-selection")
}
