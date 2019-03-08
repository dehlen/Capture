import Foundation
import Cocoa

class CaptureApplication: NSApplication {
    //swiftlint:disable:next cyclomatic_complexity
    override func sendEvent(_ event: NSEvent) {
        if event.type == .keyDown {
            if event.modifierFlags.contains(.command) {
                switch event.charactersIgnoringModifiers!.lowercased() {
                case "x":
                    if NSApp.sendAction(#selector(NSText.cut(_:)), to: nil, from: self) { return }
                case "c":
                    if NSApp.sendAction(#selector(NSText.copy(_:)), to: nil, from: self) { return }
                case "v":
                    if NSApp.sendAction(#selector(NSText.paste(_:)), to: nil, from: self) { return }
                case "a":
                    if NSApp.sendAction(#selector(NSText.selectAll(_:)), to: nil, from: self) { return }
                default:
                    break
                }
            }
        }
        return super.sendEvent(event)
    }
}
