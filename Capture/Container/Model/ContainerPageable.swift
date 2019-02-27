import AppKit

protocol ActionNameObserver {
    func didChangeActionName(newValue: String)
}

protocol ContainerPageable: class {
    var viewController: NSViewController { get }
    var actionName: String { get }
    var actionNameObservers: [ActionNameObserver] { get set }

    func triggerAction(sender: NSButton, then handler: @escaping (Result<NextContainer>) -> Void)
    func register(observer: ActionNameObserver)
    func actionNameDidChange(newValue: String)
}

extension ContainerPageable {
    func actionNameDidChange(newValue: String) {
        actionNameObservers.forEach { $0.didChangeActionName(newValue: newValue) }
    }

    func register(observer: ActionNameObserver) {
        actionNameObservers.append(observer)
    }
}

extension ContainerPageable where Self: NSViewController {
    var viewController: NSViewController {
        return self
    }
}
