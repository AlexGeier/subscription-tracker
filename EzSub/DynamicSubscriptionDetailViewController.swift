//
//  DynamicSubscriptionDetailViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class DynamicSubscriptionDetailViewController: UIViewController {
    var subscription: DynamicSubscription?
    @IBOutlet weak var totalPaidLabel: UILabel!
    @IBOutlet weak var averagePaidLabel: UILabel!
    
    @IBOutlet weak var payButton: UIButton!
    
    @IBOutlet weak var amountField: UITextField!
    
    var totalPayment: Double = 0
    var numberOfPayments = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (subscription?.payedThisMonth ?? true) {
            payButton.isEnabled = false
        }
        
        let query = PFQuery(className: "DynamicPayment")
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
                self.numberOfPayments += 1
                let month = payment["month"] as! Int
                let year = payment["year"] as! Int
                let subscriptionId = payment["subscriptionId"] as! String
                let user = payment["user"] as! PFUser
            }
            
            DispatchQueue.main.async {
                self.totalPaidLabel.text = String(format: "$%.2f", self.totalPayment)
                if (self.numberOfPayments == 0) {
                    self.averagePaidLabel.text = "$0.00"
                } else {
                    self.averagePaidLabel.text = String(format: "$%.2f", (self.totalPayment / Double(self.numberOfPayments)))
                }
            }
        }
        
    }
    
    @IBAction func onPaySubscriptionPressed(_ sender: Any) {
        payButton.isEnabled = false
        let query = PFQuery(className: "DynamicSubscription")
        
        query.getObjectInBackground(withId: (subscription?.id)!) { (object, error) in
            if (error != nil) {
                return
            }
            if (object != nil) {
                object?["payedThisMonth"] = true
                
                object?.saveInBackground(block: { (result, error) in
                    let payment = PFObject(className: "DynamicPayment")
                    let text = self.amountField.text ?? "0.00"
                    payment["amount"] = Double(text)
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
                            
                            let text = self.amountField.text ?? "0.00"
                            self.totalPayment += Double(text) ?? 0.00
                            self.numberOfPayments += 1
                            
                            DispatchQueue.main.async {
                                self.totalPaidLabel.text = String(format: "$%.2f", self.totalPayment)
                                self.averagePaidLabel.text = String(format: "$%.2f", (self.totalPayment / Double(self.numberOfPayments)))
                            }
                    } else {
                        print("SUBSCRIPTION SAVE ERROR: \(error)")
                    }
                }
            })
        }
    }
}
}
