//
//  ViewController.swift
//  EzSub
//
//  Created by Wei Nie on 3/30/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class LoginViewController: UIViewController {
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    @IBAction func onLoginButtonPressed(_ sender: Any) {
        let username = usernameField.text!
        let password = passwordField.text!
        PFUser.logInWithUsername(inBackground: username, password:password) {
            (user, error) in
            if user != nil{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)            }
            else{
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
    @IBAction func onSignUpButtonPressed(_ sender: Any) {
        let user = PFUser()
        
        user.username = usernameField.text
        user.password = passwordField.text
        user.signUpInBackground{(success, error) in
            if success{
                self.performSegue(withIdentifier: "loginSegue", sender: nil)
            }else{
                print("Error: \(error?.localizedDescription)")
            }
        }
    }
}

