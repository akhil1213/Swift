//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: AnyObject) {
        
        let email = emailTextfield?.text
        let password = passwordTextfield?.text
        Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
            if error != nil {
                print(error!)
            }else{
                print("success")
                self.performSegue(withIdentifier: "goToChat", sender: self)//we are inside of a closure which are functions without names, compiler gets confused, so in order to call a method inside of a closure you have to specify where the method occurs. performSegue method comes from the inheritance of uiviewcontroller
            }
        }
    } 
    
    
}
