import Cocoa
import QuartzCore
import Carbon.HIToolbox

//swiftlint:disable:next type_body_length
class CropView: NSView {
    weak var delegate: CropViewDelegate?
    var isInFullscreen = false

    private let selectionBox = SelectionBox()
    private let selectionHandlers = [SelectionHandler(), SelectionHandler(), SelectionHandler(), SelectionHandler()]
    private let overlayBox = OverlayBox()

    private var selectionIsActive = false
    private var selectionResizingIsActive = -1
    private var selectionMovingIsActive = false
    private var previousCropBox: NSRect = .zero
    private(set) var cropBox: NSRect = .zero {
        didSet {
            if oldValue == .zero && cropBox != .zero {
                guard let cutoutWindow = window as? CutoutWindow else { return }
                delegate?.didSelectNewCropView(on: cutoutWindow)
            }
        }
    }
    private var startingPoint: NSPoint = .zero
    private var eventMonitor: Any?
    
    private lazy var recordingButton: FlatButton = {
        let recordingButton = FlatButton(title: "startRecording".localized, target: self, action: #selector(recordingButtonPressed))
        recordingButton.activeBorderColor = .lightGray
        recordingButton.activeButtonColor = .darkGray
        recordingButton.activeTextColor = .lightGray
        recordingButton.borderColor = .white
        recordingButton.buttonColor = .darkGray
        recordingButton.textColor = .white
        recordingButton.cornerRadius = recordingButton.frame.height / 2
        return recordingButton
    }()

    private lazy var fullscreenButton: FlatButton = {
        let fullscreenButton = FlatButton(title: "toggleFullscreen".localized, target: self, action: #selector(fullscreenButtonPressed))
        fullscreenButton.activeBorderColor = .lightGray
        fullscreenButton.activeButtonColor = .darkGray
        fullscreenButton.activeTextColor = .lightGray
        fullscreenButton.borderColor = .white
        fullscreenButton.buttonColor = .darkGray
        fullscreenButton.textColor = .white
        fullscreenButton.cornerRadius = fullscreenButton.frame.height / 2
        return fullscreenButton
    }()

    private lazy var buttonStackView: NSStackView = {
        let stackView = NSStackView(views: [recordingButton, fullscreenButton])
        stackView.distribution = .fill
        stackView.spacing = 20
        stackView.orientation = .vertical
        return stackView
    }()

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)

        clearCropBox()
        registerKeyEvents()
        addButtons()
    }

    required init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showCrop(at frame: NSRect, initial: Bool) {
        DispatchQueue.main.async {
            if initial {
                self.initializeCropBox(coordinate: frame.origin)
            }
            self.cropBox = frame
            self.updateCropBox()
        }
    }

    private func addButtons() {
        buttonStackView.isHidden = true
        addSubview(buttonStackView)
    }

    @objc func recordingButtonPressed() {
        guard let cutoutWindow = window as? CutoutWindow else { return }
        delegate?.shouldStartRecording(cutoutWindow: cutoutWindow)
    }

    @objc func fullscreenButtonPressed() {
        guard let window = window else { return }
        isInFullscreen.toggle()
        if isInFullscreen {
            fullscreenButton.textColor = NSColor.controlAccentColor
            previousCropBox = cropBox
            showCrop(at: window.frame, initial: false)
        } else {
            fullscreenButton.textColor = NSColor.white
            showCrop(at: previousCropBox, initial: false)
        }
    }

    private func registerKeyEvents() {
        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            self.keyDown(with: $0)
            return $0
        }
    }

    override func keyDown(with event: NSEvent) {
        switch Int(event.keyCode) {
        case kVK_Escape:
            stop()
        default:
            super.keyDown(with: event)
        }
    }

    private func stop() {
        removeEventMonitor()
        delegate?.shouldCancelSelection()
    }

    private func removeEventMonitor() {
        if let eventMonitor = eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }

    func cancel() {
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
        if mouseOnButtons(coordinate) {
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
            initializeCropBox(coordinate: coordinate)
        }

        updateCropBox()
    }

    private func initializeCropBox(coordinate: NSPoint) {
        selectionIsActive = true
        spanCropBox(startingPoint, endPoint: coordinate)
        layer?.insertSublayer(overlayBox, below: buttonStackView.layer)
        layer?.addSublayer(selectionBox)
        selectionBox.initializeAnimation()

        layer?.addSublayer(selectionHandlers[0])
        layer?.addSublayer(selectionHandlers[1])
        layer?.addSublayer(selectionHandlers[2])
        layer?.addSublayer(selectionHandlers[3])
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
        buttonStackView.isHidden = true
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

        positionButtons()
    }

    private func positionButtons() {
        buttonStackView.isHidden = false

        if cropBox.width < buttonStackView.frame.width || cropBox.height < buttonStackView.frame.height {
            buttonStackView.frame.origin.x = cropBox.midX - buttonStackView.frame.width / 2
            buttonStackView.frame.origin.y = cropBox.minY - buttonStackView.frame.height - 10

        } else {
            buttonStackView.frame.origin.x = cropBox.midX - buttonStackView.frame.width / 2
            buttonStackView.frame.origin.y = cropBox.midY - buttonStackView.frame.height / 2
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

    private func mouseOnButtons(_ coordinate: NSPoint) -> Bool {
        if !buttonStackView.isHidden && buttonStackView.frame.insetBy(dx: -50, dy: -50).contains(coordinate) {
            return true
        }

        return false
    }
}
