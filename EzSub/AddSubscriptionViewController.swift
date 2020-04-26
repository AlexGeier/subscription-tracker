//
//  AddSubscriptionViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/5/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

enum SubscriptionType {
    case fixed
    case dynamic
}

struct Notification {
    var id:String
    var title:String
    var datetime:DateComponents
}


class LocalNotificationManager
{
    var notifications = [Notification]()
    
    func listScheduledNotifications()
    {
        UNUserNotificationCenter.current().getPendingNotificationRequests { notifications in

            for notification in notifications {
                print(notification)
            }
        }
    }
    
    private func scheduleNotifications()
    {
        for notification in notifications
        {
            let content      = UNMutableNotificationContent()
            content.title    = notification.title
            content.sound    = .default

            let trigger = UNCalendarNotificationTrigger(dateMatching: notification.datetime, repeats: false)

            let request = UNNotificationRequest(identifier: notification.id, content: content, trigger: trigger)

            UNUserNotificationCenter.current().add(request) { error in

                guard error == nil else { return }

                print("Notification scheduled! --- ID = \(notification.id)")
            }
        }
    }
    
    private func requestAuthorization()
    {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in

            if granted == true && error == nil {
                self.scheduleNotifications()
            }
        }
    }
    
    func schedule()
    {
        UNUserNotificationCenter.current().getNotificationSettings { settings in

            switch settings.authorizationStatus {
            case .notDetermined:
                self.requestAuthorization()
            case .authorized, .provisional:
                self.scheduleNotifications()
            default:
                break // Do nothing
            }
        }
    }

}

class AddSubscriptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var subscriptionName: UITextField!
    @IBOutlet weak var subscriptionAmount: UITextField!
    @IBOutlet weak var billingDatePicker: UIPickerView!
    @IBOutlet weak var subscriptionAmountStackView: UIStackView!
    @IBOutlet weak var subscriptionTypeSegmentedControl: UISegmentedControl!
    
    var subscriptionType: SubscriptionType = .fixed
    
    
    
    
    @IBAction func onSubscriptionTypeChange(_ sender: Any) {
        if (subscriptionTypeSegmentedControl.selectedSegmentIndex == 0) {
            subscriptionType = .fixed
            subscriptionAmountStackView.isHidden = false
        } else {
            subscriptionType = .dynamic
            subscriptionAmount.text = ""
            subscriptionAmountStackView.isHidden = true
        }
    }
    
    @IBAction func createSubscription(_ sender: Any) {
        if (subscriptionType == .fixed) {
            let subscription = PFObject(className: "FixedSubscription")
            subscription["name"] = subscriptionName.text!
            subscription["amount"] = Double(subscriptionAmount.text!)
            subscription["user"] = PFUser.current()!
            subscription["billingDay"] = billingDatePicker.selectedRow(inComponent: 0) + 1
            subscription["payedThisMonth"] = false
            subscription["notification"] = true
        
            let manager = LocalNotificationManager()
            
            manager.notifications = [
                Notification(id: "Payment Due", title: subscription["name"] as! String, datetime: DateComponents(calendar: Calendar.current, day: subscription["billingDay"] as! Int, hour: 23, minute: 30))]
            manager.schedule()
            
            
            
            subscription.saveInBackground { (success, error) in
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("SUBSCRIPTION SAVE ERROR: \(error)")
                }
            }
        } else {
            let subscription = PFObject(className: "DynamicSubscription")
            subscription["name"] = subscriptionName.text!
            subscription["user"] = PFUser.current()!
            subscription["billingDay"] = billingDatePicker.selectedRow(inComponent: 0) + 1
            subscription["payedThisMonth"] = false
            subscription["notification"] = true
            
            let manager = LocalNotificationManager()
            
            manager.notifications = [
                Notification(id: "Payment Due", title: subscription["name"] as! String, datetime: DateComponents(calendar: Calendar.current, day: subscription["billingDay"] as! Int, hour: 23, minute: 30))]
            manager.schedule()
            
            subscription.saveInBackground { (success, error) in
                if success {
                    self.navigationController?.popViewController(animated: true)
                } else {
                    print("SUBSCRIPTION SAVE ERROR: \(error)")
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        billingDatePicker.delegate = self
        billingDatePicker.dataSource = self
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 31
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(String(row + 1))\(getOrdinal(number: row + 1)) of the month"
    }
    
    func getOrdinal(number: Int) -> String {
        let j = number % 10
        let k = number % 100
        
        if (j == 1 && k != 11) {
            return "st"
        }
        if (j == 2 && k != 12) {
            return "nd"
        }
        if (j == 3 && k != 13) {
            return "rd"
        }
        return "th"
    }
}
