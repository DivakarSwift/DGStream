//
//  DGStreamTabBarViewController.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

enum DGStreamTabBarItem: Int {
    case recents = 0
    case contacts = 1
    case messages = 2
}

class DGStreamTabBarViewController: CustomTransitionViewController {
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var rightButtonAnchorCenterXConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tabBar: UITabBar!
    
    @IBOutlet weak var initialUserImageViewContainerCenterX: NSLayoutConstraint!
    @IBOutlet weak var initialUserImageViewContainerCenterY: NSLayoutConstraint!
    @IBOutlet weak var initialUserImageViewContainerWidth: NSLayoutConstraint!
    @IBOutlet weak var initialUserImageViewContainerHeight: NSLayoutConstraint!
    
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    
    @IBOutlet weak var initialUserImageViewContainer: UIView!
    @IBOutlet weak var blackoutView: UIView!
    
    @IBOutlet weak var initialUserImageView: UIImageView!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var lastLoggedInLabel: UILabel!
    
    var recents:[DGStreamRecent] = []
    var contacts:[DGStreamContact] = []
    var conversations:[DGStreamConversation] = []
    
    var isSelectingRows:Bool = false
    var selectedRows:[(row: Int, count: Int)] = []
    var selectedItem:DGStreamTabBarItem = .recents
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.emptyLabel.alpha = 0
        
        self.rightButton.backgroundColor = UIColor.dgBlack()
        self.rightButton.layer.cornerRadius = self.rightButton.frame.size.width / 2
        if let user = DGStreamCore.instance.currentUser, let username = user.username {
            let abrev = NSString(string: username).substring(to: 1)
            if abrev.characters.count > 0 {
                self.rightButton.setTitle(abrev, for: .normal)
                self.rightButton.setTitleColor(.white, for: .normal)
                self.rightButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
            }
        }
        
        self.view.backgroundColor = UIColor.dgBackground()
        self.blackoutView.backgroundColor = UIColor.dgBlueDark()
                
        // Data
        loadRecents()
        loadContacts()
        loadConversations()

        // Nav Bar
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        self.navTitleLabel.textColor = UIColor.dgBackground()
        
        //Table View
        self.tableView.estimatedRowHeight = 70
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.tabBar.tintColor = UIColor.dgBlueDark()
        self.tabBar.unselectedItemTintColor = UIColor.dgBlack()
        self.tabBar.selectedItem = self.tabBar.items?.first
        self.tabBar.delegate = self
        
        self.setUpButtons()
        
        self.tabBar.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideoCall(notification:)), name: Notification.Name("RestartVideoCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartAudioCall(notification:)), name: Notification.Name("RestartAudioCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptIncomingCall(notification:)), name: Notification.Name("AcceptIncomingCall"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DGStreamCore.instance.getOnlineUsers()
        
        self.rightButtonAnchorCenterXConstraint.constant = -3.5
        self.navBarView.layoutIfNeeded()
        
        self.initialUserImageView.backgroundColor = UIColor.dgBlack()
        self.initialUserImageView.layer.cornerRadius = self.initialUserImageView.frame.size.width / 2
        
        self.welcomeLabel.textColor = .white
        self.lastLoggedInLabel.textColor = .white
        
        if let currentUser = DGStreamCore.instance.currentUser {
            
            if let imageData = currentUser.image, let image = UIImage.init(data: imageData) {
                self.initialUserImageView.image = image
                self.abrevLabel.isHidden = true
            }
            else {
                self.abrevLabel.text = NSString(string: currentUser.username ?? "?").substring(to: 1)
                self.abrevLabel.textColor = .white
            }
            
            self.welcomeLabel.text = "Welcome \(currentUser.username ?? "Unknown")"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            
            self.lastLoggedInLabel.text = "Last Seen: \(dateFormatter.string(from: Date()))"
        }
        
        self.tableView.reloadData()
        DGStreamCore.instance.presentedViewController = self
    }
    
    func viewTapped() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        
        if self.blackoutView.isHidden == false {
            showInitialViews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25, execute: {
                self.animateInitialViews()
            })
        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DropDown" {
            
            var size = CGSize(width: 320, height: 200)
            if Display.pad {
                size = CGSize(width: 400, height: 200)
            }
            
            let dropDownVC = segue.destination as! DGStreamUserDropDownViewController
            dropDownVC.preferredContentSize = size
            dropDownVC.modalPresentationStyle = .popover
            dropDownVC.popoverPresentationController!.delegate = self
            dropDownVC.isModalInPopover = false
            dropDownVC.delegate = self
        }
    }
    
    func showInitialViews() {
        UIView.animate(withDuration: 0.25) {
            self.initialUserImageViewContainer.alpha = 1
            self.welcomeLabel.alpha = 1
            self.lastLoggedInLabel.alpha = 1
        }
    }
    
    func animateInitialViews() {
        
        let initialRect = self.view.convert(self.initialUserImageViewContainer.frame, to: self.blackoutView)
        let endRect = CGRect(x: self.view.bounds.size.width - (10 + 44), y: 10, width: 44, height: 44)
        
        self.initialUserImageViewContainer.isHidden = true
        
        let animateImageView = UIImageView(frame: initialRect)
        animateImageView.clipsToBounds = true
        animateImageView.image = self.initialUserImageView.image
        animateImageView.backgroundColor = UIColor.dgBlack()
        animateImageView.layer.cornerRadius = animateImageView.frame.size.width / 2
        self.blackoutView.addSubview(animateImageView)
    
        UIView.animate(withDuration: 1.25, animations: {
            self.blackoutView.backgroundColor = .clear
            self.welcomeLabel.alpha = 0
            self.lastLoggedInLabel.alpha = 0
            animateImageView.frame = endRect
            animateImageView.layer.cornerRadius = endRect.size.width / 2
            self.blackoutView.layoutIfNeeded()
        }) { (f) in
            self.blackoutView.isHidden = true
            self.rightButton.alpha = 1
            
            if self.selectedItem == .recents, self.recents.count == 0 {
                self.emptyLabel.text = "No Recents"
                self.emptyLabel.alpha = 1
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpButtons() {
        self.videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.videoCallButton.tintColor = UIColor.dgBackground()
        self.videoCallButton.backgroundColor = UIColor.dgBlueDark()
        self.videoCallButton.layer.cornerRadius = self.videoCallButton.frame.size.width / 2
        self.videoCallButton.alpha = 0
        
        self.audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.audioCallButton.tintColor = UIColor.dgBackground()
        self.audioCallButton.backgroundColor = UIColor.dgBlueDark()
        self.audioCallButton.layer.cornerRadius = self.audioCallButton.frame.size.width / 2
        self.audioCallButton.alpha = 0
        
        self.messageButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.messageButton.tintColor = UIColor.dgBackground()
        self.messageButton.backgroundColor = UIColor.dgBlueDark()
        self.messageButton.layer.cornerRadius = self.messageButton.frame.size.width / 2
        self.messageButton.alpha = 0
        
        self.leftButton.setTitleColor(UIColor.dgBackground(), for: .normal)
        self.leftButton.alpha = 0
    }
    
    //MARK:- Load Data
    func loadRecents() {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.recents = DGStreamRecent.createDGStreamRecentsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recentsWithUserIDs: [currentUserID]))
            print("Loadded Recents \(self.recents.count)")
            self.emptyLabel.alpha = 0
            if self.recents.count == 0 {
                self.emptyLabel.text = "No Recents"
                self.emptyLabel.alpha = 1
            }
        }
    }
    
    func loadContacts() {
        if let currentUser = DGStreamCore.instance.currentUser, let userID = currentUser.userID {
            self.contacts = DGStreamContact.createDGStreamContactsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, contactsForUserID: userID)).reversed()
            print("Loaded Contacts \(self.contacts.count)")
            self.emptyLabel.alpha = 0
            if self.contacts.count == 0 {
                self.emptyLabel.text = "No Contacts"
                self.emptyLabel.alpha = 1
            }
        }
    }

    func loadConversations() {
        
        let extendedRequest = ["sort_desc" : "last_message_date_sent"]
        
        let page = QBResponsePage(limit: 200, skip: 0)
        
        QBRequest.dialogs(for: page, extendedRequest: extendedRequest, successBlock: { (response: QBResponse, dialogs: [QBChatDialog]?, dialogsUsersIDs: Set<NSNumber>?, page: QBResponsePage?) -> Void in
            
            var chatDialogs:[QBChatDialog] = []
            
            if let currentUser = DGStreamCore.instance.currentUser,
                let currentUserID = currentUser.userID,
                let dialogs = dialogs {
                for chatDialog in dialogs {
                    if let occupantIDs = chatDialog.occupantIDs, occupantIDs.contains(currentUserID), chatDialog.type == .private {
                        chatDialogs.append(chatDialog)
                    }
                }
                
                let conversations = DGStreamConversation.createDGStreamConversationsFrom(chatDialogs: chatDialogs)
                for conversation in conversations {
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: conversation)
                }
                self.conversations = conversations.sorted(by: { (first, second) -> Bool in
                    var firstOtherUsername = ""
                    for userID in first.userIDs {
                        if userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID) {
                            firstOtherUsername = user.username ?? ""
                            break
                        }
                    }
                    var secondOtherUsername = ""
                    for userID in second.userIDs {
                        if userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID) {
                            secondOtherUsername = user.username ?? ""
                            break
                        }
                    }
                    return firstOtherUsername < secondOtherUsername
                })
            }
            
            self.emptyLabel.alpha = 0
            if self.conversations.count == 0 {
                self.emptyLabel.text = "No Conversations"
                self.emptyLabel.alpha = 1
            }
            
        }) { (response: QBResponse) -> Void in
            
        }
        
//        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
//            self.conversations = DGStreamConversation.createDGStreamConversationsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, conversationsWithCurrentUser: currentUserID))
//            print("Loaded Conversations \(self.conversations.count)")
//            if self.conversations.count == 0 {
//                self.emptyLabel.text = "No Messages"
//                self.emptyLabel.alpha = 1
//            }
//        }
    }
    
    func add(conversation: DGStreamConversation) {
        if selectedItem == .messages {
            self.conversations.append(conversation)
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [IndexPath.init(row: self.conversations.count - 1, section: 0)], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    func callUsers(userIDs: [NSNumber], for type: QBRTCConferenceType) {
        
        let session = QBRTCClient.instance().createNewSession(withOpponents: userIDs, with: type)
        print("Session is \(session)")
        if DGStreamCore.instance.isReachable && session.state == .new {
            if let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
                
                let otherUserID = userIDs.first!
                
                for c in self.conversations {
                    print("\(c.conversationID) | \(c.userIDs)")
                    if c.userIDs.contains(otherUserID) {
                        let proto = DGStreamConversation.createDGStreamConversationFrom(proto: c)
                        let newConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                        newConversation.type = .callConversation
                        chatVC.chatConversation = newConversation
                        print("SET NEW CONVERSATION")
                        break
                    }
                }
                
                chatVC.delegate = callVC
                callVC.chatVC = chatVC
                callVC.session = session
                callVC.selectedUser = otherUserID
                if type == .audio {
                    callVC.isAudioCall = true
                }
                
                DGStreamCore.instance.audioPlayer.ringFor(receiver: false)
                self.navigationController?.popToViewController(self, animated: false)
                self.navigationController?.pushViewController(callVC, animated: false)
            }
        }
        else {
            let alert = UIAlertController(title: "Error", message: "Unable to create session.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    func acceptCallWith(session: QBRTCSession) {
        if let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
            
            let otherUserID = session.initiatorID
            
            for c in self.conversations {
                print("\(c.conversationID) | \(c.userIDs)")
                if c.userIDs.contains(otherUserID) {
                    let proto = DGStreamConversation.createDGStreamConversationFrom(proto: c)
                    let newConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                    newConversation.type = .callConversation
                    chatVC.chatConversation = newConversation
                    print("SET NEW CONVERSATION")
                    break
                }
            }
            
            chatVC.delegate = callVC
            callVC.chatVC = chatVC
            callVC.session = session
            callVC.selectedUser = otherUserID
            if session.conferenceType == .audio {
                callVC.isAudioCall = true
            }
            
            DGStreamCore.instance.audioPlayer.ringFor(receiver: false)
            self.navigationController?.popToViewController(self, animated: false)
            self.navigationController?.pushViewController(callVC, animated: false)
        }
    }
    
    func getSelectedUsers() -> [NSNumber] {
        var userIDs: [NSNumber] = []
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            for row in self.selectedRows {
                switch selectedItem {
                case .recents:
                    
                    let recent = self.recents[row.row]
                    if let receiverID = recent.receiverID, let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, receiverID != currentUserID {
                        userIDs.append(receiverID)
                    }
                    else if let senderID = recent.senderID {
                        userIDs.append(senderID)
                    }
                    
                    break
                case .contacts:
                    
                    let contact = self.contacts[row.row]
                    if let userID = contact.userID, userID != currentUserID {
                        userIDs.append(userID)
                    }
                    
                    break
                case .messages:
                    break
                }
                
            }
        }
        return userIDs
    }
    
    func messageSelectedUsers() {
        
        if DGStreamCore.instance.isReachable {
            
            // Get selected users
            var userIDs:[NSNumber] = []
            for row in self.selectedRows {
                let selectedRow = row.row
                if self.selectedItem == .contacts, let userID = self.contacts[selectedRow].userID {
                    userIDs.append(userID)
                }
                else if self.selectedItem == .recents, let senderID = self.recents[selectedRow].senderID, let receiverID = self.recents[selectedRow].receiverID {
                    var userID: NSNumber
                    if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, senderID != currentUserID {
                        userID = senderID
                    }
                    else {
                        userID = receiverID
                    }
                    userIDs.append(userID)
                }
            }
            
            var conversationID = ""
            let sorted = userIDs.sorted(by: { (first, second) -> Bool in
                return first.uintValue < second.uintValue
            })
            for (index, userID) in sorted.enumerated() {
                conversationID.append(userID.stringValue)
                
                if index < userIDs.count {
                    conversationID.append(",")
                }
            }
            
            let dialog = QBChatDialog(dialogID: conversationID, type: .private)
            dialog.occupantIDs = userIDs
            
            QBRequest.createDialog(dialog, successBlock: { (reponse, chatDialog) in
                
                if let conversation = DGStreamConversation.createDGStreamConversationsFrom(chatDialogs: [chatDialog]).first {
                    let chatVC = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as! DGStreamChatViewController
                    conversation.conversationID = conversationID
                    chatVC.chatConversation = conversation
                    self.navigationController?.pushViewController(chatVC, animated: true)
                    
                    let startConversationMessage = QBChatMessage()
                    startConversationMessage.senderID = UInt(DGStreamCore.instance.currentUser?.userID ?? 0)
                    startConversationMessage.recipientID = UInt(userIDs.filter({ (userID) -> Bool in
                        return userID != DGStreamCore.instance.currentUser?.userID ?? 0
                    }).first ?? 0)
                    startConversationMessage.text = "System Message"
                    
                    QBChat.instance.sendSystemMessage(startConversationMessage, completion: { (error) in
                        print("Did Send System Message With \(error?.localizedDescription ?? "No Error")")
                    })
                    
                }
                
            }, errorBlock: { (errorResponse) in
                print("Error creating the chat dialog \(errorResponse.error?.error?.localizedDescription ?? "No Error")")
            })
        
        }
    }
    
    func update(user: DGStreamUser, forOnline isOnline: Bool) {
        for cell in self.tableView.visibleCells {
            
            switch self.selectedItem {
            case .recents:
                
                let recentsCell = cell as! DGStreamRecentsTableViewCell
                recentsCell.update(user: user, forOnline: isOnline)
                
                break
            case .contacts:
                
                let contactsCell = cell as! DGStreamContactsTableViewCell
                contactsCell.update(user: user, forOnline: isOnline)
                
                break
            case .messages:
                
                let conversationCell = cell as! DGStreamConversationsTableViewCell
                conversationCell.update(user: user, forOnline: isOnline)
                
                break
            }
        }
    }
    
    //MARK:- Selecting
    func beginSelectingCells() {
        
        self.leftButton.setTitle("Cancel", for: .normal)
        
        self.isSelectingRows = true
        
        for cell in self.tableView.visibleCells {
            
            switch self.selectedItem {
            case .recents:
                
                let recentsCell = cell as! DGStreamRecentsTableViewCell
                recentsCell.startSelection(animated: true)
                
                break
            case .contacts:
                
                let contactsCell = cell as! DGStreamContactsTableViewCell
                contactsCell.startSelection(animated: true)
                
                break
            case .messages:
                break
            }
        }
        
        UIView.animate(withDuration: 0.20) {
            self.videoCallButton.alpha = 1
            self.audioCallButton.alpha = 1
            self.messageButton.alpha = 1
            self.leftButton.alpha = 1
        }
        
    }
    
    func stopSelectingCells(animated: Bool) {
        
        if self.isSelectingRows {
            
            self.selectedRows.removeAll()
            
            self.isSelectingRows = false
            
            for cell in self.tableView.visibleCells {
                
                switch self.selectedItem {
                case .recents:
                    
                    let recentsCell = cell as! DGStreamRecentsTableViewCell
                    recentsCell.endSelection(animated: animated)
                    
                    break
                case .contacts:
                    
                    let contactsCell = cell as! DGStreamContactsTableViewCell
                    contactsCell.endSelection(animated: animated)
                    
                    break
                case .messages:
                    break
                }
            }
            
            if animated {
                UIView.animate(withDuration: 0.20) {
                    self.videoCallButton.alpha = 0
                    self.audioCallButton.alpha = 0
                    self.messageButton.alpha = 0
                    self.leftButton.alpha = 0
                }
            }
            else {
                self.videoCallButton.alpha = 0
                self.audioCallButton.alpha = 0
                self.messageButton.alpha = 0
                self.leftButton.alpha = 0
            }
        }
        
    }
    
    func selectRow(indexPath: IndexPath) {
        if let recentsCell = self.tableView.cellForRow(at: indexPath) as? DGStreamRecentsTableViewCell {
            if !self.selectedRows.contains(where: { (row) -> Bool in
                return row.row == indexPath.row
            }) {
                // Add
                let newCount = self.selectedRows.count + 1
                let newRow:(row: Int, count: Int) = (row: indexPath.row, count: newCount)
                self.selectedRows.append(newRow)
                recentsCell.selectWith(count: newCount, animate: true)
            }
            else {
                // Removef
                if let index = self.selectedRows.index(where: { (row) -> Bool in
                    return row.row == indexPath.row
                }) {
                    self.selectedRows.remove(at: index)
                }
            }
        }
        else if let contactsCell = self.tableView.cellForRow(at: indexPath) as? DGStreamContactsTableViewCell {
            if !self.selectedRows.contains(where: { (row) -> Bool in
                return row.row == indexPath.row
            }) {
                // Add
                let newCount = self.selectedRows.count + 1
                let newRow:(row: Int, count: Int) = (row: indexPath.row, count: newCount)
                self.selectedRows.append(newRow)
                contactsCell.selectWith(count: newCount, animate: true)
            }
            else {
                // Remove
            }
        }
    }
    
    //MARK:- Button Actions
    @IBAction func leftButtonTapped(_ sender: Any) {
        if self.isSelectingRows {
            self.stopSelectingCells(animated: true)
        }
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
//        if let userVC = UIStoryboard(name: "User", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamUserViewController, let currentUser = DGStreamCore.instance.currentUser {
//            userVC.user = currentUser
//            self.present(userVC, animated: true, completion: nil)
//        }
    }
    
    @IBAction func videoCallButtonTapped(_ sender: Any) {
        callUsers(userIDs: getSelectedUsers(), for: .video)
    }
    
    @IBAction func audioCallButtonTapped(_ sender: Any) {
        callUsers(userIDs: getSelectedUsers(), for: .audio)
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        messageSelectedUsers()
    }
    
}

extension DGStreamTabBarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch selectedItem {
        case .recents:
            
//            if !self.isSelectingRows {
//                beginSelectingCells()
//            }
            //self.selectRow(indexPath: indexPath)
            
            break
        case .contacts:
            
//            if !self.isSelectingRows {
//                beginSelectingCells()
//            }
            //self.selectRow(indexPath: indexPath)
            
            break
        case .messages:
            let conversation = self.conversations[indexPath.row]
            if let int = UInt(conversation.conversationID) {
                conversation.userIDs = [NSNumber.init(value: int)]
            }
            let chatStoryboard = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream"))
            let chatVC = chatStoryboard.instantiateInitialViewController() as! DGStreamChatViewController
            chatVC.view.alpha = 1
            chatVC.chatConversation = conversation
            self.navigationController?.pushViewController(chatVC, animated: true)
            break
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedItem {
        case .recents:
            return self.recents.count
        case .contacts:
            return self.contacts.count
        case .messages:
            return self.conversations.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch selectedItem {
        case .recents:
            let cell = tableView.dequeueReusableCell(withIdentifier: "RecentsCell") as! DGStreamRecentsTableViewCell
            cell.tag = indexPath.row
            cell.configureWith(recent: recents[indexPath.row], delegate: self)
            
            if self.isSelectingRows {
                if let row = self.selectedRows.filter({ (r) -> Bool in
                    return r.row == indexPath.row
                }).first {
                    let count = row.count
                    cell.selectWith(count: count, animate: false)
                }
            }
            
            return cell
        case .contacts:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsCell") as! DGStreamContactsTableViewCell
            cell.tag = indexPath.row
            cell.configureWith(contact: contacts[indexPath.row], delegate: self)
            
            if self.isSelectingRows {
                if let row = self.selectedRows.filter({ (r) -> Bool in
                    return r.row == indexPath.row
                }).first {
                    let count = row.count
                    cell.selectWith(count: count, animate: false)
                }
            }
            
            return cell
        case .messages:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationsCell") as! DGStreamConversationsTableViewCell
            cell.configureWith(conversation: conversations[indexPath.row])
            cell.delegate = self
            return cell
        }
    }
}

extension DGStreamTabBarViewController: UITabBarDelegate {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.emptyLabel.alpha = 0
        if let streamItem:DGStreamTabBarItem = DGStreamTabBarItem(rawValue: item.tag) {
            if streamItem != selectedItem {
                selectedItem = streamItem
                switch streamItem {
                case .recents:
                    loadRecents()
                    navTitleLabel.text = "Recents"
                    break
                case .contacts:
                    loadContacts()
                    navTitleLabel.text = "Contacts"
                    break
                case .messages:
                    loadConversations()
                    navTitleLabel.text = "Messages"
                    break
                }
                
                self.stopSelectingCells(animated: false)
                tableView.reloadData()
            }
        }
    }
}

extension DGStreamTabBarViewController: DGStreamTableViewCellDelegate {
    func streamCallButtonTappedWith(userID: NSNumber, type: QBRTCConferenceType, cellIndex: Int, buttonFrame: CGRect) {
        
        let username = DGStreamCore.instance.currentUser?.username ?? "Unknown"
        
        DGStreamNotification.backgroundCall(from: DGStreamCore.instance.currentUser?.userID ?? 0, fromUsername: username, to: [userID]) { (success, errorMessage) in
            
        }
        
        if let cell = tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0)) {
            let convertedRect = cell.contentView.convert(buttonFrame, to: self.view)
            
            let expander = TransitionButton(frame: convertedRect)
            expander.backgroundColor = UIColor.dgBlueDark()
            expander.cornerRadius = buttonFrame.size.width / 2
            self.view.addSubview(expander)
            expander.stopAnimation(animationStyle: .expand, revertAfterDelay: 0.5, completion: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                    expander.removeFromSuperview()
                })
            })
            
            self.callUsers(userIDs: [userID], for: type)
        }
    }
    func userButtonTapped(userID:NSNumber) {
        if let userVC = UIStoryboard(name: "User", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamUserViewController {
            userVC.user = DGStreamCore.instance.getOtherUserWith(userID: userID)!
            self.present(userVC, animated: true, completion: nil)
        }
    }
}

extension DGStreamTabBarViewController {
    func restartVideoCall(notification: Notification) {
        let userID = notification.object as? NSNumber
        callUsers(userIDs: [userID!], for: .video)
    }
    func restartAudioCall(notification: Notification) {
        let userID = notification.object as? NSNumber
        callUsers(userIDs: [userID!], for: .audio)
    }
    func messageButtonTappedWith(userID: NSNumber) {
        if let conversation = self.conversations.filter({ (conversation) -> Bool in
            return conversation.userIDs.contains(userID)
        }).first {
            if let int = UInt(conversation.conversationID) {
                conversation.userIDs = [NSNumber.init(value: int)]
            }
            let chatStoryboard = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream"))
            let chatVC = chatStoryboard.instantiateInitialViewController() as! DGStreamChatViewController
            chatVC.view.alpha = 1
            chatVC.chatConversation = conversation
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    func acceptIncomingCall(notification: Notification) {
        if let session = notification.object as? QBRTCSession {
            acceptCallWith(session: session)
        }
    }
}

extension DGStreamTabBarViewController: DGStreamUserDropDownViewControllerDelegate {
    
    func userButtonTapped() {
        
    }
    
    func logoutTapped() {
        QBChat.instance.disconnect { (error) in
            QBRequest.logOut(successBlock: { (response) in
                self.dismiss(animated: false, completion: nil)
            }) { (errorResponse) in
                
            }
        }
    }
}

extension DGStreamTabBarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
