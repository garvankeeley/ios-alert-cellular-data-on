// MIT license

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        UIApplication.sharedApplication().setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        return true
    }

    func applicationWillEnterForeground(application: UIApplication) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        UIApplication.sharedApplication().cancelAllLocalNotifications()

        func cellDataOn() -> Bool {
            let status = Reach().connectionStatus()
            if case .Online(.WWAN) = status {
                return true
            }
            return false
        }

        if let (isQuiet, _) = AppDelegate.inQuietPeriod() where isQuiet {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            completionHandler(.NoData)
            return
        }

        if cellDataOn() {
            presentNotification()
        } else {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        }

        completionHandler(.NoData)
    }

    static func inQuietPeriod() -> (Bool, NSDate)? {
        if let date = NSUserDefaults.standardUserDefaults().objectForKey(quietDateKey) as? NSDate {
            return (date.timeIntervalSinceNow > 0, date)
        }
        return nil
    }

    func presentNotification() {
        guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
        if settings.types == .None {
            return
        }

        let notification = UILocalNotification()

        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MMM dd, hh:mm:ss"
        let dateInFormat = dateFormatter.stringFromDate(NSDate())

        notification.alertBody = "Cellular data is on (\(dateInFormat))"
        notification.soundName = UILocalNotificationDefaultSoundName
        notification.applicationIconBadgeNumber = UIApplication.sharedApplication().applicationIconBadgeNumber + 1

        UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }

}

