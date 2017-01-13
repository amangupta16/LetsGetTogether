//
//  UserProfileViewController.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/24/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class UserProfileViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    @IBOutlet weak var emailInput: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.firstNameInput.delegate = self
        self.lastNameInput.delegate = self
        emailInput.isUserInteractionEnabled = false
        emailInput.text = AppState.sharedInstance.email
        firstNameInput.text = AppState.sharedInstance.firstName
        lastNameInput.text = AppState.sharedInstance.lastName
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    @IBAction func updateProfile(_ sender: UIButton) {
        let databaseRef = FIRDatabase.database().reference()
        databaseRef.child("users").child(AppState.sharedInstance.uid!).updateChildValues(
            [
                "firstName": firstNameInput.text!,
                "lastName": lastNameInput.text!
            ]
        )
        AppState.sharedInstance.firstName = firstNameInput.text!
        AppState.sharedInstance.lastName = lastNameInput.text!
        
        databaseRef.child("events").observe(.childAdded, with: {snapshot in
            let value = snapshot.value as? NSDictionary
            let userID = value?["uid"] as? String ?? ""
            if userID == (AppState.sharedInstance.uid)! {
                databaseRef.child("events").child(snapshot.key).updateChildValues(
                    [
                        "createdBy": self.firstNameInput.text! + " " + self.lastNameInput.text!
                    ]
                )
            }
            
        })
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
