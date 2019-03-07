#if !PMKCocoaPods
import PromiseKit
#endif
import StoreKit

extension SKPayment {
    public func promise() -> Promise<SKPaymentTransaction> {
        return PaymentObserver(payment: self).promise
    }
}

private class PaymentObserver: NSObject, SKPaymentTransactionObserver {
    let (promise, seal) = Promise<SKPaymentTransaction>.pending()
    let payment: SKPayment
    var retainCycle: PaymentObserver?
    
    init(payment: SKPayment) {
        self.payment = payment
        super.init()
        SKPaymentQueue.default().add(self)
        SKPaymentQueue.default().add(payment)
        retainCycle = self
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        guard let transaction = transactions.first(where: { $0.payment == payment }) else {
            return
        }
        switch transaction.transactionState {
        case .purchased, .restored:
            queue.finishTransaction(transaction)
            seal.fulfill(transaction)
            queue.remove(self)
            retainCycle = nil
        case .failed:
            let error = transaction.error ?? PMKError.cancelled
            queue.finishTransaction(transaction)
            seal.reject(error)
            queue.remove(self)
            retainCycle = nil
        default:
            break
        }
    }
}
