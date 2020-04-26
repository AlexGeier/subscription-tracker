//
//  SettingsViewController.swift
//  EzSub
//
//  Created by Joseph Won on 4/10/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onSignOut(_ sender: Any) {
        PFUser.logOut()
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginvc = main.instantiateViewController(withIdentifier: "LoginViewController")
        let delegate = self.view.window?.windowScene?.delegate as! SceneDelegate
        
        delegate.window?.rootViewController = loginvc
    }
    
}
