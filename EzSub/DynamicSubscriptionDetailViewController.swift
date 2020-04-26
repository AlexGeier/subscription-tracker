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

    @IBAction func onPaySubscriptionPressed(_ sender: Any) {
        var query = PFQuery(className: "DynamicSubscription")

        query.getObjectInBackground(withId: (subscription?.id)!) { (object, error) in
            object?["payedThisMonth"] = true
            object?.saveInBackground()
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    
}

