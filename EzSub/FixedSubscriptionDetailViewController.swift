//
//  FixedSubscriptionDetailViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse
import UserNotifications

protocol Payment {
    var amount: Double { get }
    var month: Int { get }
    var year: Int { get }
    var subscriptionId: String { get }
    var user: PFUser { get }
}

struct FixedPayment: Payment {
    let amount: Double
    let month: Int
    let year: Int
    let subscriptionId: String
    let user: PFUser
}

class FixedSubscriptionDetailViewController: UIViewController {
    var subscription: FixedSubscription?
    
    @IBOutlet weak var payButton: UIButton!
    @IBOutlet weak var amountLabel: UILabel!
    
    @IBOutlet weak var totalPaymentLabel: UILabel!
    
    var payments = [FixedPayment]()
    
    var totalPayment: Double = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (subscription?.payedThisMonth ?? true) {
            payButton.isEnabled = false
        }
        
        amountLabel.text = String(format: "$%.2f", subscription?.amount ?? 0)
        
        let query = PFQuery(className: "FixedPayment")
        query.whereKey("user", equalTo: PFUser.current())
        query.whereKey("subscriptionId", equalTo: subscription?.id ?? "")
        query.findObjectsInBackground { (payments, error) in
            if (error != nil) {
                return
            }
            guard let payments = payments else {
                return
            }
            
            for payment in payments {
                let amount = payment["amount"] as! Double
                self.totalPayment += amount
                let month = payment["month"] as! Int
                let year = payment["year"] as! Int
                let subscriptionId = payment["subscriptionId"] as! String
                let user = payment["user"] as! PFUser
                self.payments.append(.init(amount: amount, month: month, year: year, subscriptionId: subscriptionId, user: user))
            }
            
            DispatchQueue.main.async {
                self.totalPaymentLabel.text = String(format: "$%.2f", self.totalPayment)
            }
        }
        
    }
    
    @IBAction func onPaySubscriptionPressed(_ sender: Any) {
        payButton.isEnabled = false
        let query = PFQuery(className: "FixedSubscription")
        
        query.getObjectInBackground(withId: (subscription?.id)!) { (object, error) in
            if (error != nil) {
                return
            }
            if (object != nil) {
                object?["payedThisMonth"] = true
                
                object?.saveInBackground(block: { (result, error) in
                    let payment = PFObject(className: "FixedPayment")
                    payment["amount"] = self.subscription?.amount
                    payment["user"] = PFUser.current()!
                    payment["subscriptionId"] = self.subscription?.id
                    
                    let calendar = Calendar.current
                    let date = Date()
                    let month = calendar.component(.month, from: date)
                    let year = calendar.component(.year, from: date)
                    
                    payment["month"] = month
                    payment["year"] = year
                    
                    payment.saveInBackground { (success, error) in
                        if success {
                            self.totalPayment += self.subscription?.amount ?? 0
                            
                            DispatchQueue.main.async {
                                self.totalPaymentLabel.text = String(format: "$%.2f", self.totalPayment)
                            }
                        } else {
                            print("SUBSCRIPTION SAVE ERROR: \(error)")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func notificationSwitch(_ sender: UISwitch) {
        let query = PFQuery(className: "FixedSubscription")
        let manager = LocalNotificationManager()
        
        query.getObjectInBackground(withId: (subscription?.id)!) { (object, error) in
            if (error != nil) {
                return
            }
            if (object != nil) {
                if (sender.isOn == false) {
                    object?["notification"] = false
                    
                    object?.saveInBackground { (success, error) in
                        if success {
                            print("Notification off!")
                        } else {
                            print("Notification update ERROR: \(String(describing: error))")
                        }
                    }
                } else {
                    object?["notification"] = true
                    
                    manager.notifications = [
                        Notification(id: "Payment Due", title: object?["name"] as! String, datetime: DateComponents(calendar: Calendar.current, day: object?["billingDay"] as! Int, hour: 21, minute: 45))
                    ]
                    
                    manager.schedule()
                    
                    object?.saveInBackground { (success, error) in
                        if success {
                            print("Notification on!")
                        } else {
                            print("Notification update ERROR: \(String(describing: error))")
                        }
                    }
                }
            }
        }
    }
}
