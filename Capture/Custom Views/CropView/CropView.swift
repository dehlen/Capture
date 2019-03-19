import Cocoa
import QuartzCore
import Carbon.HIToolbox

#warning("refactor")
class CropView: NSView {
    private let selectionBox = SelectionBox()
    private let selectionHandlers = [SelectionHandler(), SelectionHandler(), SelectionHandler(), SelectionHandler()]
    private let overlayBox = OverlayBox()

    private var selectionIsActive = false
    private var selectionResizingIsActive = -1
    private var selectionMovingIsActive = false

    private(set) var cropBox: NSRect = .zero
    private var startingPoint: NSPoint = .zero
    private var isRecordingStarted: Bool = false

    private lazy var recordingButton: FlatButton = {
        let recordingButton = FlatButton(title: "Start Recording", target: self, action: #selector(recordingButtonPressed))
        recordingButton.activeBorderColor = .lightGray
        recordingButton.activeButtonColor = .darkGray
        recordingButton.activeTextColor = .lightGray
        recordingButton.borderColor = .white
        recordingButton.buttonColor = .darkGray
        recordingButton.textColor = .white
        recordingButton.cornerRadius = recordingButton.frame.height / 2
        return recordingButton
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        clearCropBox()
        registerKeyEvents()
        addRecordingButton()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showCrop(at frame: NSRect) {
        DispatchQueue.main.async {
            self.clickDown(at: frame.origin)
            self.move(to: frame.origin)
            self.clickUp()
            self.clickDown(at: frame.origin)
            self.selectionResizingIsActive = 2
            self.move(to: NSPoint(x: frame.origin.x + frame.size.width, y: frame.origin.y + frame.size.height))
            self.clickUp()
        }
    }

    func recordingStarted() {
        isRecordingStarted = true
        overlayBox.isHidden = true
        recordingButton.isHidden = true
        selectionHandlers.forEach { $0.removeFromSuperlayer() }
        cropBox = cropBox.insetBy(dx: -4, dy: -4)
        updateSelectionBox()
    }

    private func addRecordingButton() {
        recordingButton.isHidden = true
        addSubview(recordingButton)
    }

    @objc func recordingButtonPressed() {
        Current.notificationCenter.post(name: .shouldStartRecording, object: nil)
    }

    private func registerKeyEvents() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Escape:
            stop()
        case kVK_Space:
            selectFullScreen()
        default:
            super.keyDown(with: event)
        }
    }

    private func selectFullScreen() {
        guard let fullScreenFrame = window?.frame else { return }
        showCrop(at: fullScreenFrame)
    }

    private func stop() {
        if !isRecordingStarted {
            Current.notificationCenter.post(name: .shouldStopSelection, object: nil)
        }
    }

    private func cancel() {
        clearCropBox()
        selectionIsActive = false
        updateCropBox()
    }

    // MARK: Mouse Events
    override func mouseDown(with theEvent: NSEvent) {
        var coordinate = self.convert(theEvent.locationInWindow, from: nil)
        coordinate.constraintToRect(frame)

        clickDown(at: coordinate)
    }

    private func clickDown(at coordinate: NSPoint) {
        if mouseOnRecordingButton(coordinate) {
            return
        }
        if selectionIsActive {
            let activeHandler = mouseOnHandler(coordinate)
            if  activeHandler > -1 {
                selectionResizingIsActive = activeHandler
                NSCursor.arrow.set()
            } else if mouseOnCropBox(coordinate) {
                selectionMovingIsActive = true
                NSCursor.closedHand.set()
            } else {
                NSCursor.arrow.set()
                clearCropBox()
            }
        }

        startingPoint = coordinate
    }

    override func mouseDragged(with theEvent: NSEvent) {
        var coordinate = self.convert(theEvent.locationInWindow, from: nil)
        coordinate.constraintToRect(frame)

        move(to: coordinate)
    }

    private func move(to coordinate: NSPoint) {
        if selectionMovingIsActive {
            cropBox.moveBy(coordinate.x - startingPoint.x, dy: coordinate.y - startingPoint.y, inFrame: frame)
            startingPoint = coordinate
            updateCropBox()
            return
        } else if selectionResizingIsActive > -1 {
            let delta = NSSize(width: coordinate.x - startingPoint.x, height: coordinate.y - startingPoint.y)

            if selectionResizingIsActive == 0 { // Bottom left
                startingPoint.x += delta.width
                startingPoint.y += delta.height
                cropBox.size.width -= delta.width
                cropBox.size.height -= delta.height
            } else if selectionResizingIsActive == 1 { // Bottom right
                startingPoint.x = cropBox.origin.x
                startingPoint.y += delta.height
                cropBox.size.width += delta.width
                cropBox.size.height -= delta.height
            } else if selectionResizingIsActive == 2 { // Top right
                startingPoint.x = cropBox.origin.x
                startingPoint.y = cropBox.origin.y
                cropBox.size.width += delta.width
                cropBox.size.height += delta.height
            } else if selectionResizingIsActive == 3 { // Top left
                startingPoint.x += delta.width
                startingPoint.y = cropBox.origin.y
                cropBox.size.width -= delta.width
                cropBox.size.height += delta.height
            }

            cropBox.origin = startingPoint
            startingPoint = coordinate
        } else {
            selectionIsActive = true
            spanCropBox(startingPoint, endPoint: coordinate)
            layer?.insertSublayer(overlayBox, below: recordingButton.layer)
            layer?.addSublayer(selectionBox)
            selectionBox.initializeAnimation()

            layer?.addSublayer(selectionHandlers[0])
            layer?.addSublayer(selectionHandlers[1])
            layer?.addSublayer(selectionHandlers[2])
            layer?.addSublayer(selectionHandlers[3])
        }

        updateCropBox()
    }

    override func mouseUp(with theEvent: NSEvent) {
        clickUp()
    }

    private func clickUp() {
        selectionResizingIsActive = -1
        selectionMovingIsActive = false
        NSCursor.arrow.set()
    }

    fileprivate func spanCropBox(_ startingPoint: NSPoint, endPoint: NSPoint) {
        let delta = NSSize(width: abs(endPoint.x - startingPoint.x),
                           height: abs(endPoint.y - startingPoint.y))

        cropBox = NSRect(x: min(startingPoint.x, endPoint.x),
                         y: min(startingPoint.y, endPoint.y),
                         width: delta.width,
                         height: delta.height)
    }

    fileprivate func clearCropBox() {
        overlayBox.removeFromSuperlayer()
        selectionBox.removeFromSuperlayer()
        selectionHandlers.forEach { $0.removeFromSuperlayer() }

        cropBox = .zero
        selectionIsActive = false
        recordingButton.isHidden = true
    }

    private func updateSelectionBox() {
        let path = CGMutablePath()
        path.move(to: CGPoint(x: cropBox.origin.x, y: cropBox.origin.y))
        path.addLine(to: CGPoint(x: cropBox.origin.x, y: cropBox.origin.y + cropBox.size.height))
        path.addLine(to: CGPoint(x: cropBox.origin.x + cropBox.size.width, y: cropBox.origin.y + cropBox.size.height))
        path.addLine(to: CGPoint(x: cropBox.origin.x + cropBox.size.width, y: cropBox.origin.y))
        path.closeSubpath()
        selectionBox.path = path
    }

    fileprivate func updateCropBox() {
        updateSelectionBox()

        let overlay = NSBezierPath(rect: frame)
        let inner = NSBezierPath(rect: cropBox)
        overlay.append(inner)
        overlay.windingRule = .evenOdd
        overlayBox.path = overlay.CGPath

        selectionHandlers[0].location = cropBox.bottomLeft()
        selectionHandlers[1].location = cropBox.bottomRight()
        selectionHandlers[2].location = cropBox.topRight()
        selectionHandlers[3].location = cropBox.topLeft()

        positionRecordingButton()
    }

    private func positionRecordingButton() {
        recordingButton.isHidden = false

        if cropBox.width < recordingButton.frame.width || cropBox.height < recordingButton.frame.height {
            recordingButton.frame.origin.x = cropBox.midX - recordingButton.frame.width / 2
            recordingButton.frame.origin.y = cropBox.minY - recordingButton.frame.height - 10

        } else {
            recordingButton.frame.origin.x = cropBox.midX - recordingButton.frame.width / 2
            recordingButton.frame.origin.y = cropBox.midY - recordingButton.frame.height / 2
        }
    }

    private func mouseOnHandler(_ coordinate: NSPoint) -> Int {
        var i = 0
        for _ in selectionHandlers {
            if selectionHandlers[i].location.bufferRect().contains(coordinate) {
                return i
            }
            i += 1
        }

        return -1
    }

    private func mouseOnCropBox(_ coordinate: NSPoint) -> Bool {
        if cropBox.contains(coordinate) {
            return true
        }

        return false
    }

    private func mouseOnRecordingButton(_ coordinate: NSPoint) -> Bool {
        if !recordingButton.isHidden && recordingButton.frame.contains(coordinate) {
            return true
        }

        return false
    }
}
