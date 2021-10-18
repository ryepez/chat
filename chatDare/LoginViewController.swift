//
//  LoginViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/23/21.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var statusText: UILabel!
    
    var currentUser: User!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        txtEmail.delegate = self
        txtPassword.delegate = self
    }
    


    @IBAction func login(_ sender: UIButton) {
        
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
       
            if (error != nil) {
                strongSelf.statusText.text = "Error check user name password"
                print(error ?? "k")
                return
            }
        
            strongSelf.statusText.text = "loggin sucess for email\(email)"
            
            strongSelf.performSegue(withIdentifier: "channelsSegue", sender: nil)
            
        }

    }
    
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func createAccount(_ sender: UIButton) {
        
        let email = txtEmail.text!
        let password = txtPassword.text!
        
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
          
            if (error != nil) {
                self.statusText.text = "Error"
                print(error as Any)
                return
            }
            
           //if we are able to create account
            self.statusText.text = "Account Created!"
        }
    }
}
