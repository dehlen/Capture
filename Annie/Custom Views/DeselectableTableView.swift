import AppKit

class DeselectableTableView: NSTableView {
    override open func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        let point = convert(event.locationInWindow, from: nil)
        let rowIndex = row(at: point)

        if rowIndex < 0 {
            deselectAll(nil)
        }
    }
}
