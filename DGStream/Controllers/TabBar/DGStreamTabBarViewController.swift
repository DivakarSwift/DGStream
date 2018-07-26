//
//  DGStreamTabBarViewController.swift
//  DGStream
//
//  Created by Brandon on 10/20/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import MobileCoreServices

enum DGStreamTabBarItem: Int {
    case recents = 0
    case contacts = 1
    case messages = 2
    case camera = 3
}

class DGStreamTabBarViewController: CustomTransitionViewController {
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    var rightButton: UIButton!
    @IBOutlet weak var rightButtonAnchorView: UIView!
    @IBOutlet weak var dropDownArrowButton: UIButton!
    
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var rightButtonContainer: UIView!
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
    var selectedItem:DGStreamTabBarItem = .contacts
    var selectedContactsOption: ContactsDropDownOption = .allContacts
    var lastItem: UITabBarItem?
    
    var videoOrientation:UIDeviceOrientation = .portrait
    
    @IBOutlet weak var emptyLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.emptyLabel.alpha = 0
        
        self.videoCallButton.alpha = 0
        self.audioCallButton.alpha = 0
        self.messageButton.alpha = 0
        
        if let user = DGStreamCore.instance.currentUser, let username = user.username {
            
            self.rightButton = UIButton(type: .custom)
            self.rightButton.alpha = 0
            self.rightButton.frame = self.rightButtonContainer.frame
            self.rightButton.backgroundColor = UIColor.dgBlack()
            self.rightButton.layer.cornerRadius = self.rightButton.frame.size.width / 2
            self.rightButton.clipsToBounds = true
            self.rightButton.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
            self.rightButton.contentMode = .scaleAspectFill
            self.rightButton.imageView?.contentMode = .scaleAspectFill
            self.rightButton.titleLabel?.font = UIFont(name: "HelveticaNueue-Bold", size: 14)
            self.rightButton.boundInside(container: self.rightButtonContainer)                        
            if let imageData = user.image, let image = UIImage(data: imageData) {
                self.rightButton.setImage(image, for: .normal)
            }
            else {
                let abrev = NSString(string: username).substring(to: 1)
                self.rightButton.setTitle(abrev, for: .normal)
            }
        }
        
        self.view.backgroundColor = .white
                
        // Data
        loadRecents(searchText: self.searchBar.text)
        loadContactsWith(option: .allContacts, searchText: self.searchBar.text)
        loadConversations(searchText: self.searchBar.text)
        
        self.dropDownButton.alpha = 1
        self.dropDownArrowButton.alpha = 1

        // Nav Bar
        //self.navBarView.backgroundColor = self.tabBar.backgroundColor
//        var height = self.navBarView.bounds.height
//        if self.navBarView.bounds.width > self.navBarView.bounds.height {
//            height = self.navBarView.bounds.width
//        }
        let dark = UIColor.dgBlack().withAlphaComponent(0.10)
        let light = UIColor.dgBlack().withAlphaComponent(0.25)
        _ = self.navBarView.addGradientBackground(firstColor: light, secondColor: dark, height: self.navBarView.frame.size.height)
        self.blackoutView.backgroundColor = UIColor.dgBlueDark()
        self.navTitleLabel.textColor = UIColor.dgBlack()
        
        //Table View
        self.tableView.estimatedRowHeight = 80
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        
        self.tabBar.tintColor = UIColor.dgButtonColor()
        self.tabBar.unselectedItemTintColor = .lightGray
        self.tabBar.selectedItem = self.tabBar.items?.first
        self.tabBar.delegate = self
        
        self.searchBar.clearBackgroundColor()
        
        self.dropDownButton.setTitleColor(UIColor.dgButtonColor(), for: .normal)
        self.dropDownButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        self.setUpButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideoCall(notification:)), name: Notification.Name("RestartVideoCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartAudioCall(notification:)), name: Notification.Name("RestartAudioCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptIncomingCall(notification:)), name: Notification.Name("AcceptIncomingCall"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
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
            
            self.welcomeLabel.text = "\(NSLocalizedString("Welcome", comment: "Welcome (user_name)")) \(currentUser.username ?? "")"
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
            
            self.lastLoggedInLabel.text = "\(NSLocalizedString("Last seen", comment: "Last seen (last_seen_date)")) \(dateFormatter.string(from: Date()))"
        }
        
        self.tableView.reloadData()
        DGStreamCore.instance.presentedViewController = self
        
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DropDown" {
            
            var size = CGSize(width: 320, height: 270)
            if Display.pad {
                size = CGSize(width: 400, height: 270)
            }
            
            let dropDownVC = segue.destination as! DGStreamUserDropDownViewController
            dropDownVC.preferredContentSize = size
            dropDownVC.modalPresentationStyle = .popover
            dropDownVC.popoverPresentationController!.delegate = self
            dropDownVC.isModalInPopover = false
            dropDownVC.delegate = self
        }
        else if segue.identifier == "ContactsDropDown" {
            
            let size = CGSize(width: 160, height: 100)
//            if Display.pad {
//                size = CGSize(width: 400, height: 100)
//            }
            
            let dropDownVC = segue.destination as! DGStreamContactsDropDownViewController
            dropDownVC.preferredContentSize = size
            dropDownVC.modalPresentationStyle = .popover
            dropDownVC.popoverPresentationController!.delegate = self
            dropDownVC.isModalInPopover = false
            dropDownVC.delegate = self
            dropDownVC.selectedOption = self.selectedContactsOption
        }
//        else if segue.identifier == "recordings", let recordingsCollectionsNav = segue.destination as? UINavigationController, let recordingsCollectionsVC = recordingsCollectionsNav.viewControllers[0] as? DGStreamRecordingCollectionsViewController {
//            recordingsCollectionsVC.delegate = self
//        }
    }
    
    func showInitialViews() {
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let imageData = currentUser.image,
            let image = UIImage(data: imageData) {
            self.initialUserImageView.clipsToBounds = true
            self.initialUserImageView.contentMode = .scaleAspectFill
            self.initialUserImageView.image = image
        }
        
        UIView.animate(withDuration: 0.25) {
            self.initialUserImageViewContainer.alpha = 1
            self.welcomeLabel.alpha = 1
            self.lastLoggedInLabel.alpha = 1
        }
    }
    
    func animateInitialViews() {
        
        let initialRect = self.view.convert(self.initialUserImageViewContainer.frame, to: self.blackoutView)
        let endRect = CGRect(x: self.view.bounds.size.width - (10 + 44), y: 24, width: 44, height: 44)
        
        self.initialUserImageViewContainer.isHidden = true
        
        let animateImageView = UIImageView(frame: initialRect)
        animateImageView.clipsToBounds = true
        animateImageView.image = self.initialUserImageView.image
        animateImageView.backgroundColor = .red
        animateImageView.layer.cornerRadius = animateImageView.frame.size.width / 2
        animateImageView.contentMode = .scaleAspectFill
        animateImageView.layer.borderColor = UIColor.yellow.cgColor
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
            animateImageView.removeFromSuperview()
            if self.selectedItem == .recents, self.recents.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No Recents", comment: "")
                self.emptyLabel.alpha = 1
            }
        }
    }
    
    func orientationDidChange() {
        for cell in self.tableView.visibleCells {
            if let cell = cell as? DGStreamConversationsTableViewCell {
                cell.setUpGradient()
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setUpButtons() {
        
        self.leftButton.setTitleColor(UIColor.dgBackground(), for: .normal)
        self.leftButton.alpha = 0
        
        self.dropDownArrowButton.setImage(UIImage(named: "down", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.dropDownArrowButton.tintColor = UIColor.dgButtonColor()
        self.dropDownArrowButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        
    }
    
    //MARK:- Load Data
    func loadRecents(searchText: String?) {
        self.dropDownArrowButton.alpha = 0
        self.dropDownButton.alpha = 0
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.recents = DGStreamRecent.createDGStreamRecentsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recentsWithUserIDs: [currentUserID]))
            if let text = searchText {
                self.recents = self.recents.filter({ (recent) -> Bool in
                    var otherUser: DGStreamUser!
                    if let receiver = recent.receiver, let receiverID = receiver.userID, receiverID != currentUserID {
                        otherUser = receiver
                    }
                    else if let sender = recent.sender {
                        otherUser = sender
                    }
                    if let username = otherUser.username, username.hasPrefix(text) {
                        return true
                    }
                    return false
                })
            }
            print("Loadded Recents \(self.recents.count)")
            self.emptyLabel.alpha = 0
            if self.recents.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No Recents", comment: "")
                self.emptyLabel.alpha = 1
            }
        }
    }
    
    func loadContactsWith(option: ContactsDropDownOption, searchText: String?) {
        self.dropDownArrowButton.alpha = 1
        self.dropDownButton.alpha = 1
        if let currentUser = DGStreamCore.instance.currentUser, let userID = currentUser.userID {
            self.contacts = DGStreamContact.createDGStreamContactsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, contactsForUserID: userID)).reversed()
            if option == .favorites {
                if let favorites = DGStreamCore.instance.getFavorites() {
                    self.contacts = self.contacts.filter({ (contact) -> Bool in
                        return favorites.contains(contact.userID ?? 0)
                    })
                }
                else {
                    self.contacts = []
                }
            }
            else if option == .experts {
                self.contacts = self.contacts.filter { (contact) -> Bool in
                    return contact.user?.username == "Ashok"
                }
            }
            if let text = searchText {
                self.contacts = self.contacts.filter({ (contact) -> Bool in
                    if let user = contact.user, let username = user.username {
                        return username.hasPrefix(text)
                    }
                    else {
                        return false
                    }
                })
            }
            print("Loaded Contacts \(self.contacts.count)")
            self.emptyLabel.alpha = 0
            if self.contacts.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No Contacts", comment: "")
                self.emptyLabel.alpha = 1
            }
        }
    }

    func loadConversations(searchText: String?) {
        self.dropDownButton.alpha = 0
        self.dropDownArrowButton.alpha = 0
        let extendedRequest = ["sort_desc" : "last_message_date_sent"]
        
        let page = QBResponsePage(limit: 1000, skip: 0)
        
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
                if let text = searchText {
                    self.conversations = self.conversations.filter({ (conversation) -> Bool in
                        if let userID = conversation.userIDs.filter({ (userID) -> Bool in
                            return userID != currentUserID
                        }).first, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username, username.hasPrefix(text) {
                            return true
                        }
                        else {
                            return false
                        }
                    })
                }
            }
            self.emptyLabel.alpha = 0
            if self.conversations.count == 0 {
                self.emptyLabel.text = NSLocalizedString("No Conversations", comment: "")
                self.emptyLabel.alpha = 1
            }
            
        }) { (response: QBResponse) -> Void in
            
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
        
        DGStreamNotification.backgroundCall(from: DGStreamCore.instance.currentUser?.userID ?? 0, fromUsername: DGStreamCore.instance.currentUser?.username ?? "", to: [userIDs[0]]) { (success, errorMessage) in
            if success {
                print("SENT PUSH")
            }
            else if let error = errorMessage {
                print("ERROR SENDING PUSH \(error)")
            }
        }
        
        func goToCallVC() {
            let session = QBRTCClient.instance().createNewSession(withOpponents: userIDs, with: type)
            //session.localMediaStream.videoTrack.videoCapture = DGStreamCore.instance.cameraCapture
            print("Session is \(session)")
            if session == nil {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to create session.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledged dismissal"), style: .cancel, handler: { (action: UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
            else if DGStreamCore.instance.isReachable && session.state == .new {
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
//                    self.navigationController?.popToViewController(self, animated: false)
//                    self.navigationController?.pushViewController(callVC, animated: false)
                    self.present(callVC, animated: false, completion: nil)
                }
            }
            else {
                let alert = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: NSLocalizedString("Unable to create session.", comment: ""), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Acknowledged dismissal"), style: .cancel, handler: { (action: UIAlertAction) in
                    alert.dismiss(animated: true, completion: nil)
                }))
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        goToCallVC()
        
//        if type == .video {
//            DGStreamCore.instance.initializeLocalVideoWith { (success) in
//                print("LocalVideo is Initialized \(success)")
//                DispatchQueue.main.async {
//                    goToCallVC()
//                }
//            }
//            print("intializeLocalVideo()")
//        }
//        else {
//            goToCallVC()
//        }
        
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
                case .camera:
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
        
        print("This is where the user is updated offline or online")
        
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
            case .camera:
                break
            }
        }
    }
    
    //MARK:- Selecting
    func beginSelectingCells() {

        self.leftButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
        
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
            case .camera:
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
                case .camera:
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
    @IBAction func dropDownTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "ContactsDropDown", sender: nil)
    }
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
    }
    
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
        self.performSegue(withIdentifier: "DropDown", sender: nil)
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
            let newRow:(row: Int, count: Int) = (row: indexPath.row, count: 1)
            self.selectedRows.append(newRow)
            let users = getSelectedUsers()
            self.callUsers(userIDs: users, for: .video)
            self.selectedRows.removeAll()
            
            break
        case .contacts:
            
//            if !self.isSelectingRows {
//                beginSelectingCells()
//            }
            let newRow:(row: Int, count: Int) = (row: indexPath.row, count: 1)
            self.selectedRows.append(newRow)
            let users = getSelectedUsers()
            self.callUsers(userIDs: users, for: .video)
            self.selectedRows.removeAll()
            
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
        case .camera:
            break
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch selectedItem {
        case .recents:
            return self.recents.count
        case .contacts:
            return self.contacts.count
        case .messages:
            return self.conversations.count
        case .camera:
            return 0
            break
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
        case .camera:
            return UITableViewCell()
        }
    }
}

extension DGStreamTabBarViewController: UISearchBarDelegate, UITabBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch self.selectedItem {
        case .recents:
            loadRecents(searchText: self.searchBar.text)
            navTitleLabel.text = NSLocalizedString("Recents", comment: "")
            break
        case .contacts:
            loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
            navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
            break
        case .messages:
            loadConversations(searchText: self.searchBar.text)
            navTitleLabel.text = NSLocalizedString("Messages", comment: "")
            break
        case .camera:
            break
        }
        self.tableView.reloadData()
    }
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        self.emptyLabel.alpha = 0
        if let streamItem:DGStreamTabBarItem = DGStreamTabBarItem(rawValue: item.tag) {
            if streamItem != selectedItem {
//                selectedItem = streamItem
                switch streamItem {
                case .recents:
                    selectedItem = streamItem
                    loadRecents(searchText: self.searchBar.text)
                    navTitleLabel.text = NSLocalizedString("Recents", comment: "")
                    break
                case .contacts:
                    selectedItem = streamItem
                    loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
                    navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
                    break
                case .messages:
                    selectedItem = streamItem
                    loadConversations(searchText: self.searchBar.text)
                    navTitleLabel.text = NSLocalizedString("Messages", comment: "")
                    break
                case .camera:
                    let alert = UIAlertController(title: "Choose Option", message: nil, preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (action: UIAlertAction) in
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.view.tag = 99
                        imagePicker.sourceType = .camera
                        imagePicker.videoQuality = .type640x480
                        imagePicker.allowsEditing = false
                        imagePicker.mediaTypes = [kUTTypeMovie] as [String]
                        imagePicker.modalPresentationStyle = .custom
                        self.videoOrientation = UIDevice.current.orientation
                        self.present(imagePicker, animated: true) {
                            tabBar.selectedItem = tabBar.items?.first
                            self.loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
                            self.selectedItem = .contacts
                            self.navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
                            self.tableView.reloadData()
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (action: UIAlertAction) in
                        let imagePicker = UIImagePickerController()
                        imagePicker.delegate = self
                        imagePicker.view.tag = 199
                        imagePicker.sourceType = .camera
                        imagePicker.allowsEditing = false
                        imagePicker.modalPresentationStyle = .custom
                        self.present(imagePicker, animated: true) {
                            tabBar.selectedItem = tabBar.items?.first
                            self.loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
                            self.selectedItem = .contacts
                            self.navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
                            self.tableView.reloadData()
                        }
                    }))
                    alert.popoverPresentationController?.sourceView = self.view
                    alert.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.size.width - 80, y: self.tabBar.frame.y, width: 44, height: 44)
                    self.present(alert, animated: true, completion: nil)
                    break
                }
                
                self.stopSelectingCells(animated: false)
                tableView.reloadData()
            }
        }
        self.lastItem = item
    }
}

extension DGStreamTabBarViewController: DGStreamTableViewCellDelegate {
    func streamCallButtonTappedWith(userID: NSNumber, type: QBRTCConferenceType, cellIndex: Int, buttonFrame: CGRect) {
        
        let username = DGStreamCore.instance.currentUser?.username ?? ""
        
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
            userVC.delegate = self
            if let nav = self.navigationController {
                nav.pushViewController(userVC, animated: true)
            }
            else {
                self.present(userVC, animated: true, completion: nil)
            }
        }
    }
    func accessoryButtonTapped(userID: NSNumber) {
        self.userButtonTapped(userID: userID)
    }
}

extension DGStreamTabBarViewController: DGStreamUserViewControllerDelegate {
    func userViewController(_ vc: DGStreamUserViewController, didTap: CommnicationType, forUserID userID: NSNumber) {
        if didTap == .video {
            self.callUsers(userIDs: [userID], for: .video)
        }
        else if didTap == .audio {
            self.callUsers(userIDs: [userID], for: .audio)
        }
        else {
            self.messageButtonTappedWith(userID: userID)
        }
    }
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
            chatVC.isInCall = false
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
    func acceptIncomingCall(notification: Notification) {
        if let session = notification.object as? QBRTCSession {
            acceptCallWith(session: session)
        }
    }
}

extension DGStreamTabBarViewController: DGStreamContactsDropDownViewControllerDelegate {
    func contactsDropdown(_ dropDown: DGStreamContactsDropDownViewController, didTap: ContactsDropDownOption) {
        dropDown.dismiss(animated: true, completion: nil)
        if self.selectedItem == .contacts {
            self.selectedContactsOption = didTap
            self.loadContactsWith(option: didTap, searchText: self.searchBar.text)
            self.dropDownButton.setTitle(didTap.rawValue, for: .normal)
            self.tableView.reloadData()
        }
    }
}

extension DGStreamTabBarViewController: DGStreamUserDropDownViewControllerDelegate {
    
    func recordingsButtonTapped() {
        if let recordingsCollectionNav = UIStoryboard(name: "Recording", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() {
            self.present(recordingsCollectionNav, animated: true, completion: nil)
        }
    }
    
    func userButtonTapped() {
        
        func presentActionsheet() {
            let alert = UIAlertController(title: "", message: "Choose Source", preferredStyle: .actionSheet)
            alert.popoverPresentationController?.sourceView = self.view
            alert.popoverPresentationController?.sourceRect = self.rightButtonAnchorView.frame
            alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
                guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                    print("This device doesn't have a camera.")
                    return
                }
                
                let photoPicker = UIImagePickerController()
                photoPicker.sourceType = .camera
                photoPicker.delegate = self
                photoPicker.modalPresentationStyle = .custom
                self.present(photoPicker, animated: true) {
                    
                }
            }))
            alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction) in
                guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
                    print("This device doesn't have a camera.")
                    return
                }
                
                let photoPicker = UIImagePickerController()
                photoPicker.sourceType = .savedPhotosAlbum
                photoPicker.delegate = self
                photoPicker.modalPresentationStyle = .custom
                self.present(photoPicker, animated: true) {
                    
                }
            }))
            self.present(alert, animated: true) {
                
            }
        }
        
        if let presentedViewController = self.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: {
                presentActionsheet()
            })
        }
        else {
            presentActionsheet()
        }
    
    }
    
    func logoutTapped() {
        DGStreamCore.instance.unregisterFromRemoteNotifications {
            QBChat.instance.disconnect { (error) in
                QBRequest.logOut(successBlock: { (response) in
                    UserDefaults.standard.removeObject(forKey: "LastUser")
                    UserDefaults.standard.synchronize()
                    self.dismiss(animated: false, completion: nil)
                }) { (errorResponse) in
                    
                }
            }
        }
    }
}

extension DGStreamTabBarViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true) {
            
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: true)
        }
        
        if picker.view.tag == 99 {
            
            guard let image = info[UIImagePickerControllerMediaURL] as? URL else {
                return
            }
            
            if let url = info[UIImagePickerControllerMediaURL] as? URL {
                
                let recordingTitle = UUID().uuidString.components(separatedBy: "-").first!
                
                var recordingURL = DGStreamFileManager.applicationDocumentsDirectory()
                recordingURL.appendPathComponent("\(recordingTitle)")
                recordingURL.appendPathExtension("mov")
                
                do {
                    try FileManager.default.moveItem(at: url, to: recordingURL)
                }
                catch let error {
                    print("ERROR Moving item \(error.localizedDescription)")
                }
                
                encodeVideo(videoUrl: recordingURL) { (resultURL) in
                    if let encodedURL = resultURL {
                        let avAsset = AVAsset(url: encodedURL)
                        let assetGenerator = AVAssetImageGenerator(asset: avAsset)
                        assetGenerator.generateCGImagesAsynchronously(forTimes: [kCMTimeZero as NSValue], completionHandler: { (time, image, time2, result, error) in
                            
                            if error == nil, let image = image {
                                
                                let originalThumbnail = UIImage(cgImage: image)
                                
                                var newThumbnail: UIImage!
                                
                                if self.videoOrientation == .portrait {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 90.0, unit: .degrees))
                                }
                                else if self.videoOrientation == .landscapeRight {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 180.0, unit: .degrees))
                                }
                                else if self.videoOrientation == .portraitUpsideDown {
                                    newThumbnail = originalThumbnail.rotated(by:  Measurement(value: 270.0, unit: .degrees))
                                }
                                else {
                                    newThumbnail = originalThumbnail
                                }
                                
                                if let error = error {
                                    print("Failed To Merge Audio and Video \(error.localizedDescription)")
                                }
                                print("MERGED AUDIO AND VIDEO")
                                let thumbnailData = UIImageJPEGRepresentation(newThumbnail, 0.5)
                                DispatchQueue.main.async {
                                    saveRecordingsWith(fileName: recordingTitle, thumbnail: thumbnailData)
                                }
                                
                                
                            }
                            
                        })
                    }
                }
                
                func saveRecordingsWith(fileName: String, thumbnail: Data?) {
                    
                    print("SAVING RECORDING")
                    
                    let date = Date()
                    
                    let recordingCollection = DGStreamRecordingCollection()
                    recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                    recordingCollection.createdDate = date
                    recordingCollection.documentNumber = "01234-56789"
                    recordingCollection.numberOfRecordings = Int16(1)
                    recordingCollection.thumbnail = thumbnail
                    recordingCollection.title = "01234-56789"
                    
                    let recording = DGStreamRecording()
                    recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                    recording.createdDate = date
                    recording.documentNumber = "01234-56789"
                    recording.title = fileName
                    recording.thumbnail = thumbnail
                    recording.url = fileName
                    recording.isPhoto = false
                    DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
                }
                
            }
            
        }
        else if picker.view.tag == 199 {
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            
            let recordingTitle = UUID().uuidString.components(separatedBy: "-").first!
            
            func saveRecordingsWith(fileName: String, thumbnail: Data?) {
                
                print("SAVING RECORDING")
                
                let date = Date()
                
                let recordingCollection = DGStreamRecordingCollection()
                recordingCollection.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                recordingCollection.createdDate = date
                recordingCollection.documentNumber = "01234-56789"
                recordingCollection.numberOfRecordings = Int16(1)
                recordingCollection.thumbnail = thumbnail
                recordingCollection.title = "01234-56789"
                
                let recording = DGStreamRecording()
                recording.createdBy = DGStreamCore.instance.currentUser?.userID ?? 0
                recording.createdDate = date
                recording.documentNumber = "01234-56789"
                recording.title = fileName
                recording.thumbnail = thumbnail
                recording.url = fileName
                recording.isPhoto = true
                DGStreamManager.instance.dataStore.streamManager(DGStreamManager.instance, store: recording, into: recordingCollection)
            }
            
            var path = DGStreamFileManager.applicationDocumentsDirectory()
            path.appendPathComponent(recordingTitle)
            path.appendPathExtension("jpeg")
            
            if let data = UIImageJPEGRepresentation(image, 1.0),
                !FileManager.default.fileExists(atPath: path.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: path)
                    print("file saved")
                } catch {
                    print("error saving file:", error)
                }
            }
            
            saveRecordingsWith(fileName: recordingTitle, thumbnail: UIImageJPEGRepresentation(image, 0.5))
        }
        else {
            print(info)
            // get the image
            guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
                return
            }
            
            let newWidth = image.size.width / 2
            let newHeight = image.size.height / 2
            
            let smallerImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: newWidth, height: newHeight))
            
            // do something with it
            self.sendUser(image: smallerImage)
        }
    }
    
    func encodeVideo(videoUrl: URL, outputUrl: URL? = nil, resultClosure: @escaping (URL?) -> Void ) {
        
        var finalOutputUrl: URL? = outputUrl
        
        if finalOutputUrl == nil {
            var url = videoUrl
            url.deletePathExtension()
            url.appendPathExtension("mp4")
            finalOutputUrl = url
        }
        
        if FileManager.default.fileExists(atPath: finalOutputUrl!.path) {
            print("Converted file already exists \(finalOutputUrl!.path)")
            resultClosure(finalOutputUrl)
            return
        }
        
        let asset = AVURLAsset(url: videoUrl)
        if let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) {
            exportSession.outputURL = finalOutputUrl!
            exportSession.outputFileType = AVFileTypeMPEG4
            let start = CMTimeMakeWithSeconds(0.0, 0)
            let range = CMTimeRangeMake(start, asset.duration)
            exportSession.timeRange = range
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronously() {
                
                switch exportSession.status {
                case .failed:
                    print("Export failed: \(exportSession.error != nil ? exportSession.error!.localizedDescription : "No Error Info")")
                case .cancelled:
                    print("Export canceled")
                case .completed:
                    resultClosure(finalOutputUrl!)
                default:
                    break
                }
            }
        } else {
            resultClosure(nil)
        }
    }
    
    func sendUser(image: UIImage) {
        
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let fileID = UUID().uuidString.components(separatedBy: "-").first {
            
            func uploadUserImage(userID: NSNumber, fileID: String) {
                
                print("UPLOADING USER IMAGE")
                
                let userImage = QBCOCustomObject()
                userImage.className = "UserImage"
                userImage.createdAt = Date()
                userImage.userID = userID.uintValue
                userImage.id = fileID
                
                let imageFile = QBCOFile()
                if let imageData = UIImagePNGRepresentation(image) {
                    
                    imageFile.contentType = "image/png"
                    imageFile.data = imageData
                    imageFile.name = "image"
                    
                    let fields:NSMutableDictionary = NSMutableDictionary()
                    fields.setObject(imageFile, forKey: "image" as NSCopying)
                    
                    userImage.fields = fields
                }
                else {
                    
                }
                
                QBRequest.createObject(userImage, successBlock: { (response, object) in
                    
                    QBRequest.uploadFile(imageFile, className: "UserImage", objectID: object?.id ?? "", fileFieldName: "image", successBlock: { (response, uploadInfo) in
                        
                        if response.isSuccess, let object = object, let objectID = object.id {
                            print("SUCCESSFULLY UPLOADED USER IMAGE")
                            currentUser.image = UIImagePNGRepresentation(image)
                            self.rightButton.setImage(image, for: .normal)
                        }
                        else if let responseError = response.error, let error = responseError.error {
                            print("Upload Failed with error \(error.localizedDescription)")
                            //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                        }
                        else {
                            //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                        }
                        
                    }, statusBlock: { (response, status) in
                        
                    }, errorBlock: { (error) in
                        print("DID FAIL TO UPLOAD IMAGE \(error.error?.error?.localizedDescription ?? "ERROR")")
                        // self.delegate.drawOperationFailedWith(errorMessage: "Failed To Upload Image")
                    })
                    
                }, errorBlock: { (response) in
                    if let responseError = response.error, let error = responseError.error {
                        print("Upload Failed with error \(error.localizedDescription)")
                    }
                    //self.delegate.drawOperationFailedWith(errorMessage: "Failed To Create Image Object")
                })
                
            }
            
            let extendedRequest = NSMutableDictionary()
            extendedRequest.setObject(currentUser.userID?.uintValue ?? 0, forKey: "user_id" as NSCopying)
            
            QBRequest.objects(withClassName: "UserImage", extendedRequest: extendedRequest, successBlock: { (response, objects, responsePage) in
                
                // Already Exists, Delete
                if let object = objects?.first, let objectID = object.id {
                    QBRequest.deleteObject(withID: objectID, className: "UserImage", successBlock: { (response) in
                        uploadUserImage(userID: currentUserID, fileID: fileID)
                    }, errorBlock: { (errorResponse) in
                        uploadUserImage(userID: currentUserID, fileID: fileID)
                    })
                }
                else {
                    // Doesn't Already Exist, Create
                    uploadUserImage(userID: currentUserID, fileID: fileID)
                }

            }, errorBlock: { (errorResponse) in
                
            })
            
        }
        
    }
    
}

extension DGStreamTabBarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
