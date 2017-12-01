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
        
        self.view.backgroundColor = UIColor.dgBackground()
        self.blackoutView.backgroundColor = UIColor.dgGreen()
                
        // Data
        loadRecents()
        loadContacts()
        loadConversations()

        // Nav Bar
        self.navBarView.backgroundColor = UIColor.dgGray()
        self.navTitleLabel.textColor = UIColor.dgBackground()
        
        //Table View
        self.tableView.estimatedRowHeight = 70
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.tabBar.backgroundColor = UIColor.dgGreen()
        self.tabBar.barTintColor = UIColor.dgGreen()
        self.tabBar.tintColor = UIColor.dgGray()
        self.tabBar.unselectedItemTintColor = .white
        self.tabBar.delegate = self
        
        self.setUpButtons()
        
        self.tabBar.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.initialUserImageView.backgroundColor = UIColor.dgGray()
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
            self.lastLoggedInLabel.text = "Last Seen \(currentUser.lastSeen ?? Date())"
        }
        
        self.tableView.reloadData()
        DGStreamCore.instance.presentedViewController = self
    }
    
    func viewTapped() {
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.blackoutView.isHidden == false {
            showInitialViews()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25, execute: {
                self.animateInitialViews()
            })
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
        animateImageView.backgroundColor = .red
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
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpButtons() {
        self.videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.videoCallButton.tintColor = UIColor.dgBackground()
        self.videoCallButton.backgroundColor = UIColor.dgGreen()
        self.videoCallButton.layer.cornerRadius = self.videoCallButton.frame.size.width / 2
//        self.videoCallButton.layer.shadowPath = UIBezierPath(roundedRect: self.videoCallButton.frame, cornerRadius: self.videoCallButton.frame.size.width / 2).cgPath
//        self.videoCallButton.layer.shadowColor = UIColor.black.cgColor
//        self.videoCallButton.layer.shadowRadius = 10.0
//        self.videoCallButton.layer.shadowOpacity = 0.75
        self.videoCallButton.alpha = 0
        
        self.audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.audioCallButton.tintColor = UIColor.dgBackground()
        self.audioCallButton.backgroundColor = UIColor.dgGreen()
        self.audioCallButton.layer.cornerRadius = self.audioCallButton.frame.size.width / 2
//        self.audioCallButton.layer.shadowPath = UIBezierPath(roundedRect: self.audioCallButton.frame, cornerRadius: self.audioCallButton.frame.size.width / 2).cgPath
//        self.audioCallButton.layer.shadowColor = UIColor.black.cgColor
//        self.audioCallButton.layer.shadowRadius = 6.0
//        self.audioCallButton.layer.shadowOpacity = 0.75
        self.audioCallButton.alpha = 0
        
        self.messageButton.setImage(UIImage.init(named: "message", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.messageButton.tintColor = UIColor.dgBackground()
        self.messageButton.backgroundColor = UIColor.dgGreen()
        self.messageButton.layer.cornerRadius = self.messageButton.frame.size.width / 2
//        self.messageButton.layer.shadowPath = UIBezierPath(roundedRect: self.messageButton.frame, cornerRadius: self.messageButton.frame.size.width / 2).cgPath
//        self.messageButton.layer.shadowColor = UIColor.black.cgColor
//        self.messageButton.layer.shadowRadius = 10.0
//        self.messageButton.layer.shadowOpacity = 0.75
        self.messageButton.alpha = 0
        
        self.leftButton.setTitleColor(UIColor.dgBackground(), for: .normal)
        self.leftButton.alpha = 0
    }
    
    //MARK:- Load Data
    func loadRecents() {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.recents = DGStreamRecent.createDGStreamRecentsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recentsWithUserID: currentUserID))
            print("Loadded Recents \(self.recents.count)")
            if self.recents.count == 0 {
                self.emptyLabel.text = "No Recents"
                self.emptyLabel.alpha = 1
            }
        }
    }
    
    func loadContacts() {
        if let currentUser = DGStreamCore.instance.currentUser, let userID = currentUser.userID {
            self.contacts = DGStreamContact.createDGStreamContactsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, contactsForUserID: userID))
            print("Loaded Contacts \(self.contacts.count)")
            if self.contacts.count == 0 {
                self.emptyLabel.text = "No Contacts"
                self.emptyLabel.alpha = 1
            }
        }
    }

    func loadConversations() {
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.conversations = DGStreamConversation.createDGStreamConversationsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, conversationsWithCurrentUser: currentUserID))
            print("Loaded Conversations \(self.conversations.count)")
            if self.conversations.count == 0 {
                self.emptyLabel.text = "No Messages"
                self.emptyLabel.alpha = 1
            }
        }
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
        
        if DGStreamCore.instance.isReachable {
            
            if let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamCallViewController, let chatVC = UIStoryboard.init(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamChatViewController {
                
                let conversation = DGStreamConversation()
                conversation.conversationID = "0"
                conversation.userIDs = userIDs
                conversation.type = .callConversation
                
                chatVC.chatConversation = conversation
                chatVC.delegate = callVC
                callVC.chatVC = chatVC
                callVC.session = QBRTCClient.instance().createNewSession(withOpponents: userIDs, with: type)
                callVC.selectedUser = userIDs.first
                if type == .audio {
                    callVC.isAudioCall = true
                }
                DGStreamCore.instance.audioPlayer.ringFor(receiver: false)
                self.present(callVC, animated: false, completion: {
                    
                })
                
            }
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
                let i = index + 1
                if i < userIDs.count {
                    conversationID.append(",")
                }
            }
            
            conversationID = UUID().uuidString.components(separatedBy: "-").first!
            
            // Find or create conversation
            var conversation:DGStreamConversation
            if let proto = DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, conversationsWithID: conversationID) {
                let foundConversation = DGStreamConversation.createDGStreamConversationFrom(proto: proto)
                conversation = foundConversation
            }
            else {
                
                let newConversation = DGStreamConversation()
                newConversation.conversationID = conversationID
                newConversation.userIDs = userIDs
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: newConversation)
                conversation = newConversation
            }
            
            if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
                DGStreamNotification.conversationRequest(for: conversationID, from: currentUserID, to: userIDs.first!, containingUserIDs: userIDs, with: { (success, errorMessage) in
                    if success {
                        
                    }
                    else {
                        
                    }
                })
            }
            
            
            let chatVC = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as! DGStreamChatNavigationController
            chatVC.chatConversation = conversation
            
            self.navigationController?.pushViewController(chatVC, animated: true)
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
                // Remove
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
            
            if !self.isSelectingRows {
                beginSelectingCells()
            }
            
            self.selectRow(indexPath: indexPath)
            
            break
        case .contacts:
            
            if !self.isSelectingRows {
                beginSelectingCells()
            }
            
            self.selectRow(indexPath: indexPath)
            
            break
        case .messages:
            let conversation = self.conversations[indexPath.row]
            // Test
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
//        switch selectedItem {
//        case .recents:
//            return 70
//        case .contacts:
//            return 70
//        case .messages:
//            return 70
//        }
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
        
        if let cell = tableView.cellForRow(at: IndexPath(row: cellIndex, section: 0)) {
            let convertedRect = cell.contentView.convert(buttonFrame, to: self.view)
            
            let expander = TransitionButton(frame: convertedRect)
            expander.backgroundColor = UIColor.dgGreen()
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
}
