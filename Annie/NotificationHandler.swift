import Foundation
import UserNotifications

class NotificationHandler {
    static func send(gifUrl: URL) throws {
        guard UserDefaults.standard[.sendNotifications] == true else { return }
        let content = UNMutableNotificationContent()
        content.title = "newGifTitle".localized
        content.subtitle = "newGifSubtitle".localized
        content.sound = UNNotificationSound.default()
        content.categoryIdentifier = LocalNotification.Category.newGif
        content.userInfo = ["gifUrl": gifUrl.absoluteString]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

        let requestIdentifier = "NewGifNotificationRequest"
        let request = UNNotificationRequest(identifier: requestIdentifier, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request, withCompletionHandler: { (error) in
            if let error = error {
                print(error)
            }
        })
    }
}
