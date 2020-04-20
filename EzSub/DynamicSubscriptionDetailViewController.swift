//
//  DynamicSubscriptionDetailViewController.swift
//  EzSub
//
//  Created by Alex Geier on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit

class DynamicSubscriptionDetailViewController: UIViewController {
    
    @IBAction func onDeleteSubscription(_ sender: Any) {
        var flag = 0// yes or no flag
        let alert = UIAlertController(title: "Alert", message: "Are you sure?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (action: UIAlertAction!) in
            flag = 1
            
        }))
        
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
}

