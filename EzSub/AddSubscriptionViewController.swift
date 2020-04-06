//
//  AddSubscriptionViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/5/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit

class AddSubscriptionViewController: UIViewController {
    @IBOutlet weak var subscriptionName: UITextField!
    @IBOutlet weak var subscriptionAmount: UITextField!
    
    @IBAction func createSubscription(_ sender: Any) {
        // TODO: Create a fixed amount subscription with:
        // name: subscriptionName.text
        // amount: subscriptionAmount.text toDecimal
        // user: PFUser.currentUser
        
        // If creation successful:
        navigationController?.popViewController(animated: true)
        
        // else display error message
    }
}
