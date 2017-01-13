//
//  LoginViewController.swift
//  letsGetTogether
//
//  Created by macbook_user on 11/12/16.
//  Copyright © 2016 Kaustubh. All rights reserved.
//

import UIKit
import Firebase
import Foundation
import FirebaseDatabase

struct Segues {
    static let SignInToMain = "SignInToMain"
}

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var passWord: UITextField!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameInput: UITextField!
    @IBOutlet weak var lastNameInput: UITextField!
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        super.touchesBegan(touches, with: event)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if let user = FIRAuth.auth()?.currentUser {
            self.signedIn(user)
        }
        self.firstNameInput.alpha = 0
        self.firstNameLabel.alpha = 0
        self.lastNameInput.alpha = 0
        self.lastNameLabel.alpha = 0
        self.userName.delegate = self
        self.passWord.delegate = self
        self.firstNameInput.delegate = self
        self.lastNameInput.delegate = self
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func Login(_ sender: UIButton) {
        // Sign In with credentials.
        if self.firstNameInput.alpha == 1 {
            self.firstNameInput.alpha = 0
            self.firstNameLabel.alpha = 0
            self.lastNameInput.alpha = 0
            self.lastNameLabel.alpha = 0
            return
        }
        
        guard let email = userName.text, let password = passWord.text else { return }
        FIRAuth.auth()?.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                
                let alertController = UIAlertController(
                    title: "Invalid Credentials",
                    message: error.localizedDescription,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let confirmAction = UIAlertAction(
                title: "OK", style: UIAlertActionStyle.default) { (action) in
                    // ...
                }
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
                
                return
            }
            self.signedIn(user!)
        }
    }

    @IBAction func signUp(_ sender: UIButton) {
        if self.firstNameInput.alpha == 0 {
            self.firstNameInput.alpha = 1
            self.firstNameLabel.alpha = 1
            self.lastNameInput.alpha = 1
            self.lastNameLabel.alpha = 1
            return
        }
        guard let email = userName.text, let password = passWord.text else { return }
        FIRAuth.auth()?.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                
                let alertController = UIAlertController(
                    title: "Error",
                    message: error.localizedDescription,
                    preferredStyle: UIAlertControllerStyle.alert
                )
                
                let confirmAction = UIAlertAction(
                title: "OK", style: UIAlertActionStyle.default) { (action) in
                    // ...
                }
                
                alertController.addAction(confirmAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            self.setDisplayName(user!)
        }
    }
    
    @IBAction func forgotPassword(_ sender: UIButton) {
        
        let prompt = UIAlertController.init(title: nil, message: "Enter Your Email Id:", preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Send Password Reset Link", style: .default) { (action) in
            let userInput = prompt.textFields![0].text
            if (userInput!.isEmpty) {
                return
            }
            FIRAuth.auth()?.sendPasswordReset(withEmail: userInput!) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
            }
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil);
        
    }
    
    
    func setDisplayName(_ user: FIRUser) {
        let changeRequest = user.profileChangeRequest()
        changeRequest.displayName = user.email!.components(separatedBy: "@")[0]
        changeRequest.commitChanges(){ (error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            self.signedIn(FIRAuth.auth()?.currentUser)
        }
    }
    
    func signedIn(_ user: FIRUser?) {
        AppState.sharedInstance.displayName = user?.displayName ?? user?.email
        AppState.sharedInstance.signedIn = true
        
        let uid = (user?.uid)!;
        let databaseRef = FIRDatabase.database().reference()
        
        databaseRef.child("users").observe(.value, with: {snapshot in
            if snapshot.hasChild(uid) {
                databaseRef.child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    // Get user value
                    let value = snapshot.value as? NSDictionary
                    print("User is already existing !!!!")
                    AppState.sharedInstance.uid = value?["uid"] as? String ?? ""
                    AppState.sharedInstance.firstName = value?["firstName"] as? String ?? ""
                    AppState.sharedInstance.lastName = value?["lastName"] as? String ?? ""
                    AppState.sharedInstance.email = value?["email"] as? String ?? ""
                    AppState.sharedInstance.interestedEvents = value?["interestedEvents"] as? [String] ?? []
                })
            } else {
                print("User is not existing and hence creating a new user !!!!")
                let post : [String : AnyObject] = ["uid" : uid as AnyObject,
                                                   "firstName" : (self.firstNameInput.text)! as AnyObject,
                                                   "lastName" : (self.lastNameInput.text)! as AnyObject,
                                                   "email" : (user?.email)! as AnyObject,
                                                   "interestedEvents": [] as AnyObject]
                AppState.sharedInstance.uid = uid
                AppState.sharedInstance.firstName = self.firstNameInput.text!
                AppState.sharedInstance.lastName = self.lastNameInput.text!
                AppState.sharedInstance.email = (user?.email)!
                databaseRef.child("users").child(uid).setValue(post)
            }
        })
        performSegue(withIdentifier: Segues.SignInToMain, sender: nil)
        //databaseRef.child("users").child(uid).setValue(post)
    }

    
}
