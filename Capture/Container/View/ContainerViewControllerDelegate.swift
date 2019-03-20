import Cocoa

protocol ContainerViewControllerDelegate: class {
    func requestLoadingIndicator()
    func dismissLoadingIndicator()
    func requestReplace(new: NSViewController)
    func exportProgressDidChange(progress: Double)
}
