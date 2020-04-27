//
//  FixedSubscriptionDetailViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

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
    
    @IBOutlet weak var amountLabel: UILabel!
    
    var payments = [FixedPayment]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountLabel.text = String(format: "$%.2f", subscription?.amount ?? 0)
        
        let query = PFQuery(className: "FixedPayment")
        query.whereKey("user", equalTo: PFUser.current())
        query.whereKey("subscriptionId", equalTo: subscription?.id ?? "")
        query.findObjectsInBackground { (payments, error) in
            if (error != nil) {
                return
            }
            guard let payments = payments else { return }
                        
            for payment in payments {
                let amount = payment["amount"] as! Double
                let month = payment["month"] as! Int
                let year = payment["year"] as! Int
                let subscriptionId = payment["subscriptionId"] as! String
                let user = payment["user"] as! PFUser
                self.payments.append(.init(amount: amount, month: month, year: year, subscriptionId: subscriptionId, user: user))
            }
            
            // TODO: Reload tableview after all payments have been added
            // TODO: Set total amount field
            // TODO: Set average amount field
        }
        
    }
    
    @IBAction func onPaySubscriptionPressed(_ sender: Any) {
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
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            print("SUBSCRIPTION SAVE ERROR: \(error)")
                        }
                    }
                })
            }
        }
    }
    
    @IBAction func onDeleteSubscription(_ sender: Any) {
        var flag = 0// yes or no flag
        let alert = UIAlertController(title: "Alert", message: "Are you sure?", preferredStyle: .alert)
        //TODO!!
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (action: UIAlertAction!) in
            flag = 1
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
}
