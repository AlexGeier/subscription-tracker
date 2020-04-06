//
//  AddSubscriptionViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/5/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class AddSubscriptionViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var subscriptionName: UITextField!
    @IBOutlet weak var subscriptionAmount: UITextField!
    @IBOutlet weak var billingDatePicker: UIPickerView!
    
    @IBAction func createSubscription(_ sender: Any) {
        let subscription = PFObject(className: "FixedSubscription")
        subscription["name"] = subscriptionName.text!
        subscription["amount"] = Double(subscriptionAmount.text!)
        subscription["user"] = PFUser.current()!
        subscription["billingDay"] = billingDatePicker.selectedRow(inComponent: 0) + 1
        
        subscription.saveInBackground { (success, error) in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                print("SUBSCRIPTION SAVE ERROR: \(error)")
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
