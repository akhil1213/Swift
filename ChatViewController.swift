//
//  ViewController.swift
//  Flash Chat
//
//  Created by Angela Yu on 29/08/2015.
//  Copyright (c) 2015 London App Brewery. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController , UITableViewDataSource , UITableViewDelegate , UITextFieldDelegate{
    
    
    
    // Declare instance variables here
    
    
    // We've pre-linked the IBOutlets
    @IBOutlet var heightConstraint: NSLayoutConstraint!
    @IBOutlet var sendButton: UIButton!
    @IBOutlet var messageTextfield: UITextField!
    @IBOutlet var messageTableView: UITableView!
    var messageCounter = 0
    var messageArray : [Message] = [Message]()
    var senderRandom : [String : UIColor] = [:]
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //TODO: Set yourself as the delegate and datasource here:
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        
        //TODO: Set yourself as the delegate of the text field here:
        messageTextfield.delegate = self//we can listen to whatever happens inside of our message text field, so if somebody clicks the etxt field to type we want the textfield to go to the middle of the screen instead of the bottom so the keyboard isnt covering it.
        //TODO: Set the tapGesture here:
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tableViewTapped))//calls tablefieldtapped method wheneever a tap occurs. selectors are a legacy that comes from objective c. we use selectors when we need to call functions on objects that compiler doesn't know about yet until the app is running. so table view tapped is a function that gets called from the self object i.e this class instance
        messageTableView.addGestureRecognizer(gesture)//adding a tap listener to our tableView to listen for taps
        
    
        //TODO: Register your MessageCell.xib file here:
        messageTableView.register(UINib(nibName : "MessageCell", bundle : nil), forCellReuseIdentifier: "customMessageCell")//bundle is the path but we dont need a bundle because our compiler can find the message cell in this directory. if we wanted to find it somewhere in the computer we use a bundle or some shit
        messageTableView.separatorStyle = .none
        retrieveMessages()
    }

    ///////////////////////////////////////////
    
    //MARK: - TableView DataSource Methods

    //TODO: Declare cellForRowAtIndexPath here:
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "customMessageCell", for: indexPath) as! CustomMessageCell//Returns a reusable table-view cell object for the specified reuse identifier and adds it to the table. returns a uitableviewcell. indexPath specifies what row/location each cell is on.
        
        cell.messageBody.text = messageArray[indexPath.row].messageBody//gets called for every single cell in this table view and each time the indexpath changes 
        cell.senderUsername.text  = messageArray[indexPath.row].sender
        cell.avatarImageView.image = UIImage(named : "egg") // default image
//        cell.messageBackground.backgroundColor = senderRandom[cell.senderUsername.text!]
        if cell.senderUsername.text == Auth.auth().currentUser?.email as String?{
            cell.avatarImageView.backgroundColor = UIColor.gray
            //cell.messageBackground.backgroundColor = UIColor.blue
        }else{
            cell.avatarImageView.backgroundColor = UIColor.red
            //cell.messageBackground.backgroundColor = UIColor.blue
        }
        return cell
        
    }
    //TODO: Declare tableViewTapped here:
    
    @objc func tableViewTapped(){
        messageTextfield.endEditing(true)//set the end editing to be true for the text field therefore, the textfieldDidEndEditing function is called since endEditing is set to be true
    }
    
    
    //TODO: Declare configureTableView here:
    func configureTableView(){
        messageTableView.rowHeight = UITableViewAutomaticDimension//set to equal the width of specific iphone
        messageTableView.estimatedRowHeight = 120.0
    }
    ///////////////////////////////////////////

    //MARK:- TextField Delegate Methods
    
    //TODO: Declare textFieldDidBeginEditing here:
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 308
            self.view.layoutIfNeeded() // if something in the view changed redraw the whole thing
        })
        
    }//tells the delegate/chat view controller that editing began in the specificied text field.
    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.5, animations: {
            self.heightConstraint.constant = 50
            self.view.layoutIfNeeded() // if something in the view changed redraw the whole thing
        })
    }
    
    
    //TODO: Declare textFieldDidEndEditing here:

    ///////////////////////////////////////////
    
    //MARK: - Send & Recieve from Firebase
    @IBAction func sendPressed(_ sender: AnyObject) {
        messageTextfield.endEditing(true)
        //when a user sends a message, it is time consuming for the message to go to the database get saved and displayed on the app, while that time consuming event is happening we need to disable the messagetextfield and sendpressed button and re-enable it when the message is done sending.
        messageTextfield.isEnabled = false
        sendButton.isEnabled = false
        /*setting the value of our database as a dictionary of type string as our keys and values respectively.*/
        let messageDict : [String : String] = ["sender" : (Auth.auth().currentUser?.email)! , "message" :  messageTextfield.text!]
        let messageDB = Database.database().reference().child("messages")
        messageDB.childByAutoId().setValue(messageDict){
            (error, reference) in//inside of a closure
            if error != nil{
                print(error!)
            }else{
                //there are no errors so we have sent the message, therefore we can re-enable our message text field and send button.
                self.messageTextfield.isEnabled = true
                self.sendButton.isEnabled = true
                print("success")
                self.messageTextfield.text = ""//reset our message text field to an empty string so it doesn't read the previous message sent
            }
        }
        //TODO: Send the message to Firebase and save it in our database
    }
    
    /* the function retrieve messages is called in viewDidLoad because our application needs to listen for messages. Inside of the retrieveMessages function we are observing for messages to be added in our database using an enum event handler i.e DataEventType.childAdded as our parameter and if the child has been added, we get the value of the database as a parameter from a closure. From the closure, we receive the instance of the most recent added value to our database as a parameter.*/
    func retrieveMessages(){
        let messageDB = Database.database().reference().child("messages")
        messageDB.observe(DataEventType.childAdded) { (snapshot) in
            let data = snapshot.value as! Dictionary<String, String>
            let message = data["message"]
            let sender = data["sender"]
            let messageobj = Message()
            messageobj.messageBody = message!
            messageobj.sender = sender!
            self.messageArray.append(messageobj)
            //we need to reformat the table view since we are adding messages to the table view
            self.configureTableView()
            self.messageTableView.reloadData() // calls the cellForRowAt table view method
            
        }/*dataEventtype.childAdded is a case which means that something has just been added to the database. this method is listening to the database. you can also listen if a child is removed. The datasnapshot holds the data that just has been added and it is inside of a closure as a oarameter. the closure gets called every time a new item has been added to the database and it gives access to the message text field and sender field.*/
    }
    

    
    
    
    @IBAction func logOutPressed(_ sender: AnyObject) {
        
        // Log out the user and send them back to WelcomeViewController
        do{
            try Auth.auth().signOut()
        }catch{
            print("Error trying to sign out")
        }
        navigationController?.popViewController(animated: true)//takes u back to original view controller, basically the root
        
    }
    


}
