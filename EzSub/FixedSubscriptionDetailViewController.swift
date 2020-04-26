//
//  FixedSubscriptionDetailViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class FixedSubscriptionDetailViewController: UIViewController {
    var subscription: FixedSubscription?
    
    @IBOutlet weak var amountLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        amountLabel.text = String(format: "$%.2f", subscription?.amount ?? 0)
    }
    
    @IBAction func onPaySubscriptionPressed(_ sender: Any) {
        var query = PFQuery(className: "FixedSubscription")

        query.getObjectInBackground(withId: (subscription?.id)!) { (object, error) in
            object?["payedThisMonth"] = true

            object?.saveInBackground(block: { (result, error) in
                self.navigationController?.popViewController(animated: true)
            })
           
        }
    }
}
