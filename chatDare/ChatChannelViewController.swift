//
//  ChatChannelViewController.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/26/21.
//

import UIKit
import Firebase


class ChatChannelViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //properties
    var ref: DatabaseReference!
    fileprivate var _refHandle: DatabaseHandle!
    var channels: [DataSnapshot]! = []
    var lastMessageReturn = String()

    // auth handers
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    
    //reference to the storage
    var storageRef: StorageReference!

    var user: User?
    var displayName = "Anonymous"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.rowHeight = (view.frame.height/8)

        configureAuth()
        configureDatabase()
        configureStorage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    
    func configureAuth() {
        
        //Firebase Authentication
        
        _authHandle = Auth.auth().addStateDidChangeListener({(auth: Auth, user: User?) in
        //refresh table data
            self.channels.removeAll(keepingCapacity: false)
            self.tableView.reloadData()
            
            //check if there is current user
            
            if let activeUser = user {
                //check if the current app user is the current FIRUser
                if self.user != activeUser {
                    self.user = activeUser
                    
                    let name = user!.email!.components(separatedBy: "@")[0]
                    self.displayName = name
                } else {
                    //user must sign in
                
                    let loginVC = self.storyboard?.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                    
                    
                    self.present(loginVC, animated: true, completion: nil)
                }
            }
            
        })
    }
    
    
    func configureDatabase() {
        
        ref = Database.database().reference()
        //creating a lisenser  where to lisen to changes
    
        
        _refHandle = ref.child("channels").observe(.childAdded) { (snapshot: DataSnapshot) in
            
            self.channels.append(snapshot)
            self.tableView.insertRows(at: [IndexPath(row: self.channels.count - 1, section: 0)], with: .automatic)
            self.scrollToBottomMessage()
        }
        
    }
    
    deinit {
        //this is to remove the lisenser so we do not run of memory after this class get deinit
        ref.child("channels").removeObserver(withHandle: _refHandle)
        //remove lisne
        Auth.auth().removeStateDidChangeListener(_authHandle)
        
        print("deinit")

    }
    
    func scrollToBottomMessage() {
        
        if channels.count == 0 {return}
        
        let bottomMessageIndex = IndexPath(row: tableView.numberOfRows(inSection: 0) - 1, section: 0)
        
        tableView.scrollToRow(at: bottomMessageIndex, at: .bottom, animated: true)
    }

    
    func configureStorage() {
        
        storageRef = Storage.storage().reference()
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
    
      return "Dare Chat"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //unpacking messages from firebase data snapshot
         
       
        let cell =
        tableView.dequeueReusableCell(withIdentifier: "chatChannels", for: indexPath) as! ChannelsTableViewCell
        
        let channelsSnapshot: DataSnapshot! = channels[indexPath.row]
        
        //for getting last message sent
        let keyOfTread = channelsSnapshot.key as String

        
        let recentMessageQuery = ( ref.child("channels").child(keyOfTread).child("message").queryLimited(toLast: 1))
      
        recentMessageQuery.getData { [weak self] Error, DataSnapshot   in
            
            
        guard let strongSelf = self else { return }
            
            
            if Error != nil {
                print("something went wrong")
            }
            let mydata = DataSnapshot.value as! [String:Any]
            
            if let messageID = mydata.keys.first {
                
                if let messageLast =  mydata[messageID] as? [String:Any] {
                    
                    cell.lastMessageTimeWhie.text =  messageLast["text"] as? String
                    
                    let time =  messageLast["dateSent"] as! Double
                    cell.dateOfLastmessage.text = strongSelf.convertTimestamp(serverTimestamp: time)
                }
               
            }
            
        }
        
        
        //converting to a dic
        let canales = channelsSnapshot.value as! [String:Any]
        let details = canales["details"] as! [String:Any]
        let name = details["name"] as? String
        
    
        
        
        cell.chatTittle.text = name
        cell.profileImage.image = UIImage(named: "profilepic")

        cell.accessoryType = .disclosureIndicator

        return cell
    }
    
   
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        let controller: ViewController
        controller = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        
        //sending the select chat to table chat view controller
        
        let channelsSnapshot: DataSnapshot! = channels[indexPath.row]
        
        //for getting last message sent
        let keyOfTread = channelsSnapshot.key as String

        controller.treadID = keyOfTread

        //pushing the controller to top
      
        navigationController?.pushViewController(controller, animated: true)
        
    //present(controller, animated: true, completion: nil)
        
    }
    
 
   @IBAction func addImage(_ sender: UIButton) {
       
      
       let picker = UIImagePickerController()
       picker.delegate = self
       picker.sourceType = .photoLibrary
       present(picker, animated: true, completion: nil)
   }
    
    
    
    
    @IBAction func firsTime(_ sender: UIButton) {
        
        var mdata = [String: Any]()
        
        mdata = ["creationDate" :  [".sv": "timestamp"], "lastMessageDated": [".sv": "timestamp"], "name": "Running"]
        
        //mdata["name"] = "Skydiving"
        
      //  ref.child("channels").child("details").setValue(mdata)
       
        let key = ref.childByAutoId()
        
        if let keyOfChannel = key.key {
            
        ref.child("channels").child(keyOfChannel).child("details").setValue(mdata)
            
            let userInfo = ["userName": "will"]
            
            ref.child("channels").child(keyOfChannel).child("users").setValue(userInfo)
            
            let message = ["dateSent": [".sv": "timestamp"], "text": "What?, world :) ", "useID": "will"] as [String : Any]
            
            ref.child("channels").child(keyOfChannel).child("message").childByAutoId().setValue(message)
            
            let messageTwo = ["dateSent": [".sv": "timestamp"], "text": "Hola, a todos", "useID": "ryan"] as [String : Any]
            
            ref.child("channels").child(keyOfChannel).child("message").childByAutoId().setValue(messageTwo)
      
        }
        
    //    ref.child("channels").childByAutoId().child("details").setValue(mdata)
        
    }
    
    func createChannel(data: [String:String]) {
        
        let message = ["dateSent": "10092021", "text": "Hello, world :) ", "useID": "ryepez"]
        ref.child("channels").child("-MlacdR4fmrMEixYAHdD").child("message").childByAutoId().setValue(message)
        
    }
    
    @IBAction func addChannel(_ sender: UIBarButtonItem) {
        
        //getLastMessage()
        
 
    }
    
    func getLastMessage(treadID: String) {
               
          let recentPostsQuery = ( ref.child("channels").child(treadID).child("message").queryLimited(toLast: 1))
        
        recentPostsQuery.getData { [self] Error, DataSnapshot in
              
              if Error != nil {
                  print("something went wrong")
              }
            let mydata = DataSnapshot.value as! [String:Any]
                        
            self.lastMessageReturn = mydata.keys.first!
            
          }
                
    }
    
    func convertTimestamp(serverTimestamp: Double) -> String {
            let x = serverTimestamp / 1000
            let date = NSDate(timeIntervalSince1970: x)
            let formatter = DateFormatter()
            formatter.dateStyle = .short
          //  formatter.timeStyle = .short

            return formatter.string(from: date as Date)
        }
    

}

