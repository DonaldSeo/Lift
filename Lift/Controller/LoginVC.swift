//
//  LoginVC.swift
//  Lift
//
//  Created by Donald Seo on 2020-08-08.
//  Copyright © 2020 Donald Seo. All rights reserved.
//

import Foundation
import Firebase
import UIKit


class LoginVC: UIViewController {
  
  //Constant
  let loginToList = "LoginToList"
  let ref = Database.database().reference(withPath: "User")
  
  
  @IBOutlet weak var LoginViewLogo: UIImageView!
  
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  
  override func viewDidLoad() {
    //set logo image
    
    Auth.auth().addStateDidChangeListener { auth, user in
      if user != nil {
        print("hello")
        print(user?.uid)
        if user!.isEmailVerified {
          self.performSegue(withIdentifier: self.loginToList, sender: nil)
          self.textFieldLoginEmail.text?.removeAll()
          self.textFieldLoginPassword.text?.removeAll()
        }
      } else {
        print("login failed")
      }
    }
//    Auth.auth().removeStateDidChangeListener(listener)
    
  }
  
  @IBAction func loginButtonPressed(_ sender: Any) {
    Auth.auth().signIn(withEmail: textFieldLoginEmail.text!, password: textFieldLoginPassword.text!) { (result, error) in
      if let error = error, let _ = AuthErrorCode(rawValue: error._code) {
        print("login not working")
        print(error.localizedDescription)
      } else {
        print("login successful")
        print(result as Any)
        self.performSegue(withIdentifier: self.loginToList, sender: nil)
        self.textFieldLoginEmail.text?.removeAll()
        self.textFieldLoginPassword.text?.removeAll()
      }
    }
//
  }
  
  
  
  @IBAction func signUpButtonPressed(_ sender: Any) {
    let alert = UIAlertController(title: "Register", message: "Register Your Account", preferredStyle: .alert)
    
    let warningAlert = UIAlertController(title: "Strong Password", message: "fix your password", preferredStyle: .alert)
    let warningCancelAction = UIAlertAction(title: "Cancel", style: .default)
    warningAlert.addAction(warningCancelAction)
    
    let saveAction = UIAlertAction(title: "Register", style: .default) { action in
      
      let emailField = alert.textFields![0]
      let passwordField = alert.textFields![1]
//      self.present(warningAlert, animated: true, completion: nil)

      Auth.auth().createUser(withEmail: emailField.text!, password: passwordField.text!, completion: { AuthDataResult, error in
        if error != nil {
          if let errorCode = AuthErrorCode(rawValue: error!._code) {
            switch errorCode {
            case .weakPassword:
              print("please provide a strong password")
              self.present(warningAlert, animated: true, completion: nil)
            case .emailAlreadyInUse:
              print("please use different email. Already in Use")
            default:
              print("There is an error")
            }
          }
        }
        if AuthDataResult != nil {
          AuthDataResult?.user.sendEmailVerification(completion: { error in
            print(error?.localizedDescription)
//
          })
        }
        
        
      })
    }
    
    let cancelAction = UIAlertAction(title: "Cancel",
                                     style: .default)
    
    alert.addTextField { textEmail in
      textEmail.placeholder = "Enter your email"
    }
    
    alert.addTextField { textPassword in
      textPassword.isSecureTextEntry = true
      textPassword.placeholder = "Enter your password"
    }
    
    alert.addAction(saveAction)
    alert.addAction(cancelAction)
    
    present(alert, animated: true, completion: nil)
  }
}
