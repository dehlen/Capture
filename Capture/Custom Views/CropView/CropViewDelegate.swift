import Foundation

protocol CropViewDelegate: class {
    func didSelectNewCropView(on cutoutWindow: CutoutWindow)
    func shouldCancelSelection()
    func shouldStartRecording(cutoutWindow: CutoutWindow)
}
