// MIT license

import UIKit

extension NSTimeInterval {
    static let Minute = NSTimeInterval(60)
    static let Hour = Minute * 60
    static let Day = Hour * 24
}

let quietDateKey = "quiet_date"

class ViewController: UIViewController {

    @IBAction func buttonPressed(sender: UIButton) {
        if sender.tag > 0 {
            let quietHours = Double(sender.tag)
            let date = NSDate(timeIntervalSinceNow: quietHours * NSTimeInterval.Hour)
            NSUserDefaults.standardUserDefaults().setObject(date, forKey: quietDateKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(quietDateKey)
        }
        setup()
    }

    @IBOutlet weak var quietPeriodLabel: UILabel!
    @IBOutlet weak var buttonClear: UIButton!

    override func viewDidAppear(animated: Bool) {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(setup), name: UIApplicationWillEnterForegroundNotification, object: nil)

        setup()
    }

    func setup() {
        if let (isQuiet, date) = AppDelegate.inQuietPeriod() where isQuiet {
            buttonClear.alpha = 1
            quietPeriodLabel.alpha = 1

            let fmt = NSDateComponentsFormatter()
            fmt.unitsStyle = .Short
            fmt.allowedUnits = [.Hour, .Minute]
            guard let interval = fmt.stringFromTimeInterval(date.timeIntervalSinceNow + 60) else { return }
            quietPeriodLabel.text = "Quiet until \(interval) from now"

        } else {
            buttonClear.alpha = 0
            quietPeriodLabel.alpha = 0
        }
    }
    
}

