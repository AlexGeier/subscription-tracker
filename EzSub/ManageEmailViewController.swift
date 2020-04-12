//
//  ManageEmailViewController.swift
//  EzSub
//
//  Created by Joseph Won on 4/11/20.
//  Copyright © 2020 Terrycai. All rights reserved.
//

import UIKit
import Parse

class ManageEmailViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var confirmEmail: UITextField!
    var emailEquals = false
    
    @IBAction func OnEmailAdd(_ sender: Any) {
        let current_user = PFUser.current()
        
        //not eq. alert user
        if (email.text! != confirmEmail.text!) {
            let alert = UIAlertController(title: "Error", message: "Emails do not match.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            current_user?["email"] = email.text!
            current_user?.saveInBackground()
            self.navigationController?.popViewController(animated: true)
        }
        
        //Debuggging
//        print(current_user?.username!)
//        print(current_user?.email!)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
