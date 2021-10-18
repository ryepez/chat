//
//  ViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/6/21.
//

import UIKit
import Firebase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
   
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageMessage: UIButton!
    @IBOutlet weak var messageTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var imageViewMessage: UIImageView!
    
    
    //properties
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    var messages: [DataSnapshot]! = []
    var treadID = String()
    // auth handers
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    //reference to the storage
    var storageRef: StorageReference!

    var user: User?
    var displayName = "Anonymous"

    let imageCache = NSCache<NSString, UIImage>()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        messageTextField.delegate = self
        tableView.allowsSelection = false

        

        tableView.rowHeight = UITableView.automaticDimension
        
        tableView.estimatedRowHeight = (view.frame.height/5)

        let treadIDToUse = treadID
        
        configureAuth()
        configureDatabase(chatID: treadIDToUse)
        configureStorage()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        messages = nil
    }
    
    func configureStorage() {
        
        storageRef = Storage.storage().reference()
    }
    
    func sendPhotoMessage(photoData: Data) {
        
        //build a path using the user id and timestam
        
        let imagePath = "chat_photos/" + Auth.auth().currentUser!.uid + "/\(Double(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        print(imagePath)
        //metadata
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        //create a child note at imagepath with photoData and metada
        
        storageRef.child(imagePath).putData(photoData, metadata: metadata) {[weak self] (metadata, error) in
            
            guard let strongSelf = self else { return }
            
            if let error = error {
                print("error updaing: \(error.localizedDescription)")
                return
            }
            
            //user sendMessget to add imageURL to database
            strongSelf.sendURLtoDB(data: ["photoUrl" : strongSelf.storageRef.child((metadata?.path)!).description])
            
        }
        
        
        
    }
        
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func configureDatabase(chatID: String) {
        
        
        ref = Database.database().reference()
        //creating a lisenser  where to lisen to changes
        

        _refHandle = ref.child("channels").child(chatID).child("message").observe(.childAdded) { [weak self] (snapshot: DataSnapshot) in
            
            guard let strongSelf = self else { return }

            strongSelf.messages.append(snapshot)
            strongSelf.tableView.insertRows(at: [IndexPath(row: strongSelf.messages.count - 1, section: 0)], with: .automatic)
            strongSelf.scrollToBottomMessage()
        }
        
    }
    
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
        ref.child("channels").child(treadID).child("messages").removeObserver(withHandle: _refHandle)
        //remove lisne
        Auth.auth().removeStateDidChangeListener(_authHandle)
        
        
            print("deinit \(self)")
    }
    
   
    
    
    func configureAuth() {
        
        //Firebase Authentication
        
        _authHandle = Auth.auth().addStateDidChangeListener({ [weak self] (auth: Auth, user: User?) in
            
            guard let strongSelf = self else { return }

        //refresh table data
            strongSelf.messages.removeAll(keepingCapacity: false)
            strongSelf.tableView.reloadData()
            
            //check if there is current user
            
            if let activeUser = user {
                //check if the current app user is the current FIRUser
                if strongSelf.user != activeUser {
                    strongSelf.user = activeUser
                    
                    let name = user!.email!.components(separatedBy: "@")[0]
                    strongSelf.displayName = name
                } else {
                    //user must sign in
                
                    let loginVC = strongSelf.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                    
                    
                    strongSelf.present(loginVC, animated: true, completion: nil)
                }
            }
            
        })
    }
 
  
    func scrollToBottomMessage() {
        
        if messages.count == 0 {return}
        
        let bottomMessageIndex = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }


    
    
    
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
    
      return "Dare Chat"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
    
        //unpacking messages from firebase data snapshot
         
         let messageSnapshot: DataSnapshot! = messages[indexPath.row]
        
        let cell =
        tableView.dequeueReusableCell(withIdentifier: "messageChat", for: indexPath) as! ChatTableViewCell
        

        //converting to a dic
        
        let message = messageSnapshot.value as! [String:Any]
        let name = message["useID"] ?? "username"
        let text = message["text"] ?? "message"
        
        let imageURL = message["photoUrl"] != nil ? true : false
        
        if imageURL {
            
            let imageURL = message["photoUrl"]
            
            Storage.storage().reference(forURL: imageURL as! String).getData(maxSize: INT64_MAX) { [weak self] data, error in
                
               // guard let strongSelf = self else { return }

                guard error == nil else {
                    print("error downloding: \(error!.localizedDescription)")
                    return
                }
                
                //get image
                let messageImage = UIImage.init(data: data!, scale: 30)
             //   strongSelf.imageCache.setObject(messageImage!, forKey: "photoUrl")
                
                    //cell.messageStackView.alpha = 0.0

                    DispatchQueue.main.async {
                    cell.userName.text = name as? String
                    cell.message.text = text as? String
                    cell.messageStackView.alpha = 0.0
                    cell.imageViewMessage.alpha = 1.0
                    cell.imageViewMessage.image = messageImage
                    cell.message.text = ""
                    }
                
                
            }
            
        } else {
            
            cell.userName.text = name as? String
            cell.message.text = text as? String
            cell.imageViewMessage.alpha = 0.0
            cell.messageStackView.alpha = 1.0
            cell.messageStackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
            cell.messageStackView.isLayoutMarginsRelativeArrangement = true
            cell.messageStackView.backgroundColor = UIColor(hue: 0.5667, saturation: 0.71, brightness: 0.8, alpha: 1.0)
        }
        
        return cell
        
    }
    
    

    func curveUI(articulo: UIView) {
        
        articulo.layer.cornerRadius = 20
        articulo.layer.borderWidth = 5.0
        articulo.layer.borderColor = UIColor.white.cgColor
        articulo.clipsToBounds = true
    }
    
    
    @IBAction func didSendMessage(_ sender: UIButton) {
        
    //this call the function below that send the data to firebase
    let _ = textFieldShouldReturn(messageTextField)
    messageTextField.text = ""
                
    }
    
    func sendURLtoDB(data: [String:String]) {
        
        
        var message = ["dateSent": [".sv": "timestamp"], "useID": displayName, "text": "image" ] as [String : Any]
        
        message[data.keys.first!] = data.values.first

        ref.child("channels").child(treadID).child("message").childByAutoId().setValue(message)
    }
    
    func sendMessage(data: [String:String]) {
        
        
        let textMessage = data.values.first! as String
        let message = ["dateSent": [".sv": "timestamp"], "text":textMessage, "useID": displayName] as [String : Any]
        

        ref.child("channels").child(treadID).child("message").childByAutoId().setValue(message)
        
    }
    
    @IBAction func didTapAddPhoto(_ sender: AnyObject) {
       
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !textField.text!.isEmpty {
            let data = ["text": textField.text! as String]
            sendMessage(data: data)
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            // getting the image selected by the user
        if let image = info[.originalImage] as? UIImage,  let photoData = image.jpegData(compressionQuality: 0.8) {
            // call function to upload photo message
            sendPhotoMessage(photoData: photoData)

        }

            //dismissing the picker
            dismiss(animated: true, completion: nil)

        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    

}

