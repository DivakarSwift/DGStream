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
    case contacts = 0
    case favorites = 1
    case recents = 2
    case more = 3
}

class DGStreamTabBarViewController: CustomTransitionViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var reloadButton: UIButton!
    
    @IBOutlet weak var reloadActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var sortButton: UIButton!
    
    @IBOutlet weak var filterButton: UIButton!
    
    @IBOutlet weak var navBarView: UIView!
    
//    @IBOutlet weak var rightButtonAnchorView: UIView!
    @IBOutlet weak var dropDownArrowButton: UIButton!
    
    @IBOutlet weak var dropDownButton: UIButton!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
//    @IBOutlet weak var rightButtonContainer: UIView!
//    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
//    @IBOutlet weak var initialUserImageViewContainerCenterX: NSLayoutConstraint!
//    @IBOutlet weak var initialUserImageViewContainerCenterY: NSLayoutConstraint!
//    @IBOutlet weak var initialUserImageViewContainerWidth: NSLayoutConstraint!
//    @IBOutlet weak var initialUserImageViewContainerHeight: NSLayoutConstraint!
    
//    @IBOutlet weak var initialUserImageViewContainer: UIView!
//    @IBOutlet weak var blackoutView: UIView!
    
//    @IBOutlet weak var initialUserImageView: UIImageView!
//    @IBOutlet weak var abrevLabel: UILabel!
//    @IBOutlet weak var welcomeLabel: UILabel!
//    @IBOutlet weak var lastLoggedInLabel: UILabel!
    
    var recents:[DGStreamRecent] = []
    var contacts:[DGStreamContact] = []
    var conversations:[DGStreamConversation] = []
    var favorites:[DGStreamUser] = []
    
    var isSelectingRows:Bool = false
    var selectedRows:[(row: Int, count: Int)] = []
    var selectedItem:DGStreamTabBarItem = .contacts
    var selectedContactsOption: ContactsDropDownOption = .allContacts
    var lastItem: UITabBarItem?
        
    @IBOutlet weak var emptyLabel: UILabel!
    
    var canSelect: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TAB Loaded")
        
        self.reloadActivityIndicator.isHidden = true
        
        self.setLayout()
    
        //self.emptyLabel.alpha = 0
        
//        self.videoCallButton.alpha = 0
//        self.audioCallButton.alpha = 0
//        self.messageButton.alpha = 0
//
//        if let user = DGStreamCore.instance.currentUser, let username = user.username {
//
//            self.rightButton = UIButton(type: .custom)
//            self.rightButton.alpha = 0
//            self.rightButton.frame = self.rightButtonContainer.frame
//            self.rightButton.backgroundColor = UIColor.dgBlack()
//            self.rightButton.layer.cornerRadius = self.rightButton.frame.size.width / 2
//            self.rightButton.clipsToBounds = true
//            self.rightButton.addTarget(self, action: #selector(rightButtonTapped(_:)), for: .touchUpInside)
//            self.rightButton.contentMode = .scaleAspectFill
//            self.rightButton.imageView?.contentMode = .scaleAspectFill
//            self.rightButton.titleLabel?.font = UIFont(name: "HelveticaNueue-Bold", size: 14)
//            self.rightButton.boundInside(container: self.rightButtonContainer)
//            if let imageData = user.image, let image = UIImage(data: imageData) {
//                self.rightButton.setImage(image, for: .normal)
//            }
//            else {
//                let abrev = NSString(string: username).substring(to: 1)
//                self.rightButton.setTitle(abrev, for: .normal)
//            }
//        }
        
        self.titleLabel.alpha = 0
        
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        
        self.view.backgroundColor = UIColor.dgBG()
                
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
//        let dark = UIColor.dgBlack().withAlphaComponent(0.10)
//        let light = UIColor.dgBlack().withAlphaComponent(0.25)
//        _ = self.navBarView.addGradientBackground(firstColor: light, secondColor: dark, height: self.navBarView.frame.size.height)
//        self.blackoutView.backgroundColor = UIColor.dgBlueDark()
//        self.navTitleLabel.textColor = UIColor.dgBlack()
        
        //Table View
        //self.collectionView.estimatedRowHeight = 80
        
        self.tabBar.tintColor = .orange
        self.tabBar.unselectedItemTintColor = .lightGray
        self.tabBar.delegate = self
        
        var items:[UITabBarItem] = []
        
        let contacts = UITabBarItem(tabBarSystemItem: .contacts, tag: 0)
        items.append(contacts)
        
        let favorites = UITabBarItem(tabBarSystemItem: .favorites, tag: 1)
        items.append(favorites)
        
        let recents = UITabBarItem(tabBarSystemItem: .recents, tag: 2)
        items.append(recents)

        let more = UITabBarItem(tabBarSystemItem: .more, tag: 3)
        items.append(more)
        self.tabBar.setItems(items, animated: false)
        
        self.tabBar.selectedItem = self.tabBar.items?.first
        
        self.searchBar.clearBackgroundColor()
        
        let textField = searchBar.value(forKey: "searchField") as! UITextField
        
        let glassIconView = textField.leftView as! UIImageView
        glassIconView.image = glassIconView.image?.withRenderingMode(.alwaysTemplate)
        glassIconView.tintColor = UIColor.dgBlack()
        
        
        let clearButton = textField.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.dgBlack()
        
        for subView in searchBar.subviews {
            
            for subViewOne in subView.subviews {
                
                if let textField = subViewOne as? UITextField {
                    
                    subViewOne.backgroundColor = UIColor.dgBlackHalf()
                    
                    textField.textColor = UIColor.dgBlack()
                    textField.font = UIFont(name: "HelveticaNeue-Bold", size: 14)
                    
                    //use the code below if you want to change the color of placeholder
                    let textFieldInsideUISearchBarLabel = textField.value(forKey: "placeholderLabel") as? UILabel
                    textFieldInsideUISearchBarLabel?.textColor = UIColor.dgBlack()
                }
            }
        }
        
        self.collectionView.allowsSelection = true
        
        self.dropDownButton.setTitleColor(.white, for: .normal)
        self.dropDownButton.titleLabel?.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        
        self.setUpButtons()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartVideoCall(notification:)), name: Notification.Name("RestartVideoCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.restartAudioCall(notification:)), name: Notification.Name("RestartAudioCall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.acceptIncomingCall(notification:)), name: Notification.Name("AcceptIncomingCall"), object: nil)
        
        //NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange), name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        
    }
    
    func setLayout() {
        self.collectionView.setCollectionViewLayout(DGStreamCollectionViewLayoutTable(), animated: true) { (s) in
            self.collectionView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navBarView.layoutIfNeeded()
        
//        self.initialUserImageView.backgroundColor = UIColor.dgBlack()
//        self.initialUserImageView.layer.cornerRadius = self.initialUserImageView.frame.size.width / 2
//
//        self.welcomeLabel.textColor = .white
//        self.lastLoggedInLabel.textColor = .white
//
//        if let currentUser = DGStreamCore.instance.currentUser {
//
//            if let imageData = currentUser.image, let image = UIImage.init(data: imageData) {
//                self.initialUserImageView.image = image
//                self.abrevLabel.isHidden = true
//            }
//            else {
//                self.abrevLabel.text = NSString(string: currentUser.username ?? "?").substring(to: 1)
//                self.abrevLabel.textColor = .white
//            }
//
//            self.welcomeLabel.text = "\(NSLocalizedString("Welcome", comment: "Welcome (user_name)")) \(currentUser.username ?? "")"
//
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .short
//            dateFormatter.timeStyle = .short
//
//            self.lastLoggedInLabel.text = "\(NSLocalizedString("Last seen", comment: "Last seen (last_seen_date)")) \(dateFormatter.string(from: Date()))"
//        }
        
        self.collectionView.reloadData()
        DGStreamCore.instance.presentedViewController = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
                
//        if self.blackoutView.isHidden == false {
//            showInitialViews()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2.25, execute: {
//                self.animateInitialViews()
//            })
//        }
    
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ContactsDropDown" {
            
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
    
//    func showInitialViews() {
//
//        if let currentUser = DGStreamCore.instance.currentUser,
//            let imageData = currentUser.image,
//            let image = UIImage(data: imageData) {
//            self.initialUserImageView.clipsToBounds = true
//            self.initialUserImageView.contentMode = .scaleAspectFill
//            self.initialUserImageView.image = image
//        }
//
//        UIView.animate(withDuration: 0.25) {
//            self.initialUserImageViewContainer.alpha = 1
//            self.welcomeLabel.alpha = 1
//            self.lastLoggedInLabel.alpha = 1
//        }
//    }
    
//    func animateInitialViews() {
//
//        let initialRect = self.view.convert(self.initialUserImageViewContainer.frame, to: self.blackoutView)
//        let endRect = CGRect(x: self.view.bounds.size.width - (10 + 44), y: 24, width: 44, height: 44)
//
//        self.initialUserImageViewContainer.isHidden = true
//
//        let animateImageView = UIImageView(frame: initialRect)
//        animateImageView.clipsToBounds = true
//        animateImageView.image = self.initialUserImageView.image
//        animateImageView.backgroundColor = .red
//        animateImageView.layer.cornerRadius = animateImageView.frame.size.width / 2
//        animateImageView.contentMode = .scaleAspectFill
//        animateImageView.layer.borderColor = UIColor.yellow.cgColor
//        self.blackoutView.addSubview(animateImageView)
//
//        UIView.animate(withDuration: 1.25, animations: {
//            self.blackoutView.backgroundColor = .clear
//            self.welcomeLabel.alpha = 0
//            self.lastLoggedInLabel.alpha = 0
//            animateImageView.frame = endRect
//            animateImageView.layer.cornerRadius = endRect.size.width / 2
//            self.blackoutView.layoutIfNeeded()
//        }) { (f) in
//            self.blackoutView.isHidden = true
//            self.rightButton.alpha = 1
//            animateImageView.removeFromSuperview()
//            if self.selectedItem == .recents, self.recents.count == 0 {
//                self.emptyLabel.text = NSLocalizedString("No Recents", comment: "")
//                self.emptyLabel.alpha = 1
//            }
//        }
//    }
    
//    func orientationDidChange() {
//        for cell in self.tableView.visibleCells {
//            if let cell = cell as? DGStreamConversationsTableViewCell {
//                cell.setUpGradient()
//            }
//        }
//    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func setUpButtons() {
        self.dropDownArrowButton.setImage(UIImage(named: "down", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.dropDownArrowButton.tintColor = .white
        self.dropDownArrowButton.imageEdgeInsets = UIEdgeInsetsMake(4, 4, 4, 4)
        
        self.reloadButton.setImage(self.reloadButton.currentImage?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.reloadButton.tintColor = .white
        
        self.filterButton.setImage(UIImage.init(named: "filter", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil), for: .normal)
        self.filterButton.tintColor = .orange
        
        self.sortButton.setImage(UIImage.init(named: "sort", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil), for: .normal)
        self.sortButton.tintColor = .orange
    }
    
    //MARK:- Load Data
    func loadRecents(searchText: String?) {
        self.dropDownArrowButton.alpha = 0
        self.dropDownButton.alpha = 0
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            self.recents = DGStreamRecent.createDGStreamRecentsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recentsWithUserIDs: [currentUserID]))
            if let text = searchText, !text.isEmpty {
                self.recents = self.recents.filter({ (recent) -> Bool in
                    var otherUser: DGStreamUser?
                    if let receiver = recent.receiver, let receiverID = receiver.userID, receiverID != currentUserID {
                        otherUser = receiver
                    }
                    else if let sender = recent.sender {
                        otherUser = sender
                    }
                    guard let user = otherUser else {
                        return false
                    }
                    if let username = user.username, username.hasPrefix(text) {
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
    
    func loadFavorites(searchText: String?) {
        guard let favoriteIDs = DGStreamCore.instance.getFavorites() else { return }
        self.favorites.removeAll()
        for id in favoriteIDs {
            if let user = DGStreamCore.instance.getOtherUserWith(userID: id) {
                self.favorites.append(user)
            }
        }
        if let text = searchText {
            self.favorites = self.favorites.filter({ (contact) -> Bool in
                if let username = contact.username {
                    return username.hasPrefix(text)
                }
                else {
                    return false
                }
            })
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
//        if selectedItem == .messages {
//            self.conversations.append(conversation)
////            self.collectionView.beginUpdates()
////            self.tableView.insertRows(at: [IndexPath.init(row: self.conversations.count - 1, section: 0)], with: .fade)
////            self.tableView.endUpdates()
//        }
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
                case .favorites :
                    let user = self.favorites[row.row]
                    if let userID = user.userID, userID != currentUserID {
                        userIDs.append(userID)
                    }
                    break
                    
                case .more :
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
        
        for cell in self.collectionView.visibleCells {
            
            switch self.selectedItem {
            case .recents:
                
                let recentsCell = cell as! DGStreamRecentsTableViewCell
                recentsCell.update(user: user, forOnline: isOnline)
                
                break
            case .contacts:
                
                let contactsCell = cell as! DGStreamContactsTableViewCell
                contactsCell.update(user: user, forOnline: isOnline)
                
                break
            case .favorites :
                break
                
            case .more :
                break
            }
        }
    }
    
    //MARK:- Selecting
    func beginSelectingCells() {

//        self.leftButton.setTitle(NSLocalizedString("Cancel", comment: "Stop action"), for: .normal)
        
        self.isSelectingRows = true
        
        for cell in self.collectionView.visibleCells {
            
            switch self.selectedItem {
            case .recents:
                
                let recentsCell = cell as! DGStreamRecentsTableViewCell
                recentsCell.startSelection(animated: true)
                
                break
            case .contacts:
                
                let contactsCell = cell as! DGStreamContactsTableViewCell
                contactsCell.startSelection(animated: true)
                
                break
            case .favorites :
                break
                
            case .more :
                break
            }
        }
        
    }
    
    func stopSelectingCells(animated: Bool) {
        
        if self.isSelectingRows {
            
            self.selectedRows.removeAll()
            
            self.isSelectingRows = false
            
            for cell in self.collectionView.visibleCells {
                
                switch self.selectedItem {
                case .recents:
                    
                    let recentsCell = cell as! DGStreamRecentsTableViewCell
                    recentsCell.endSelection(animated: animated)
                    
                    break
                case .contacts:
                    
                    let contactsCell = cell as! DGStreamContactsTableViewCell
                    contactsCell.endSelection(animated: animated)
                    
                    break
                case .favorites :
                    break
                    
                case .more :
                    break
                }
            }
            
//            if animated {
//                UIView.animate(withDuration: 0.20) {
//                    self.videoCallButton.alpha = 0
//                    self.audioCallButton.alpha = 0
//                    self.messageButton.alpha = 0
//                    self.leftButton.alpha = 0
//                }
//            }
//            else {
//                self.videoCallButton.alpha = 0
//                self.audioCallButton.alpha = 0
//                self.messageButton.alpha = 0
//                self.leftButton.alpha = 0
//            }
        }
        
    }
    
    func selectRow(indexPath: IndexPath) {
        if let recentsCell = self.collectionView.cellForItem(at: indexPath) as? DGStreamRecentsTableViewCell {
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
        else if let contactsCell =
            self.collectionView.cellForItem(at: indexPath) as? DGStreamContactsTableViewCell {
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
    
    @IBAction func reloadButtonTapped(_ sender: Any) {
        self.reloadActivityIndicator.startAnimating()
        self.reloadActivityIndicator.isHidden = false
        self.reloadButton.isHidden = true
        DGStreamCore.instance.getAllUsers {
            self.collectionView.reloadData()
            self.reloadActivityIndicator.isHidden = true
            self.reloadActivityIndicator.stopAnimating()
            self.reloadButton.isHidden = false
        }
    }
    
    
    @IBAction func filterButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        
    }
    
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

extension DGStreamTabBarViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //collectionView.deselectItem(at: indexPath, animated: true)
        
        if !self.canSelect {
            return
        }
        
        if Display.pad {
            guard let split = self.splitViewController,
            let detail = split.viewControllers[1] as? DGStreamDetailViewController else { return }
            let newRow:(row: Int, count: Int) = (row: indexPath.row, count: 1)
            self.selectedRows.append(newRow)
            let users = getSelectedUsers()
            if let userID = users.first, let user = DGStreamCore.instance.getOtherUserWith(userID: userID) {
                detail.load(user: user)
            }
            self.selectedRows.removeAll()
        }
        else if Display.typeIsLike == .iphone6plus || Display.typeIsLike == .iphone7plus {
            
        }
        else {
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
            case .favorites :
                let newRow:(row: Int, count: Int) = (row: indexPath.row, count: 1)
                self.selectedRows.append(newRow)
                let users = getSelectedUsers()
                self.callUsers(userIDs: users, for: .video)
                self.selectedRows.removeAll()
                break
                
            case .more :
                break
//            case .messages:
//                let conversation = self.conversations[indexPath.row]
//                if let int = UInt(conversation.conversationID) {
//                    conversation.userIDs = [NSNumber.init(value: int)]
//                }
//                let chatStoryboard = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream"))
//                let chatVC = chatStoryboard.instantiateInitialViewController() as! DGStreamChatViewController
//                chatVC.view.alpha = 1
//                chatVC.chatConversation = conversation
//                self.navigationController?.pushViewController(chatVC, animated: true)
//                break
//            case .camera:
//                break
            }
        }
    }
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 80
//    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch selectedItem {
        case .recents:
            return self.recents.count
        case .contacts:
            return self.contacts.count
        case .favorites :
            return self.favorites.count
        case .more :
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch selectedItem {
        case .recents:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RecentsCell", for: indexPath) as! DGStreamRecentsTableViewCell
            cell.tag = indexPath.item
            cell.configureWith(recent: recents[indexPath.item], delegate: self)
            
            if self.isSelectingRows {
                if let row = self.selectedRows.filter({ (r) -> Bool in
                    return r.row == indexPath.item
                }).first {
                    let count = row.count
                    cell.selectWith(count: count, animate: false)
                }
            }
            
            return cell
        case .contacts:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsCell", for: indexPath) as! DGStreamContactsTableViewCell
            cell.tag = indexPath.item
            cell.configureWith(contact: contacts[indexPath.item], delegate: self)
            
            if self.isSelectingRows {
                if let row = self.selectedRows.filter({ (r) -> Bool in
                    return r.row == indexPath.item
                }).first {
                    let count = row.count
                    cell.selectWith(count: count, animate: false)
                }
            }
            
            return cell
        case .favorites :
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ContactsCell", for: indexPath) as! DGStreamContactsTableViewCell
            cell.tag = indexPath.item
            cell.configureWith(user: self.favorites[indexPath.item], delegate: self)
            
            if self.isSelectingRows {
                if let row = self.selectedRows.filter({ (r) -> Bool in
                    return r.row == indexPath.item
                }).first {
                    let count = row.count
                    cell.selectWith(count: count, animate: false)
                }
            }
            return cell
        case .more :
            return UICollectionViewCell()
        }
    }
    
}

extension DGStreamTabBarViewController: UISearchBarDelegate, UITabBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        switch self.selectedItem {
        case .recents:
            loadRecents(searchText: self.searchBar.text)
            //navTitleLabel.text = NSLocalizedString("Recents", comment: "")
            break
        case .contacts:
            loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
            //navTitleLabel.text = NSLocalizedString("Contacts", comment: "")
            break
        case .favorites :
            break
            
        case .more :
            break
        }
        self.collectionView.reloadData()
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
                    titleLabel.text = NSLocalizedString("Recents", comment: "")
                    self.titleLabel.alpha = 1
                    self.dropDownButton.alpha = 0
                    self.dropDownArrowButton.alpha = 0
                    break
                case .contacts:
                    selectedItem = streamItem
                    loadContactsWith(option: self.selectedContactsOption, searchText: self.searchBar.text)
                    //titleLabel.text = NSLocalizedString("Contacts", comment: "")
                    self.titleLabel.alpha = 0
                    self.dropDownButton.alpha = 1
                    self.dropDownArrowButton.alpha = 1
                    break
                case .favorites :
                    selectedItem = streamItem
                    loadFavorites(searchText: self.searchBar.text)
                    titleLabel.text = NSLocalizedString("Favorites", comment: "")
                    self.titleLabel.alpha = 1
                    self.dropDownButton.alpha = 0
                    self.dropDownArrowButton.alpha = 0
                    break
                    
                case .more :
                    selectedItem = streamItem
                    titleLabel.text = NSLocalizedString("More", comment: "")
                    self.titleLabel.alpha = 1
                    self.dropDownButton.alpha = 0
                    self.dropDownArrowButton.alpha = 0
                    break
                }
                
                self.stopSelectingCells(animated: false)
                collectionView.reloadData()
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
        
        if let cell = collectionView.cellForItem(at: IndexPath(row: cellIndex, section: 0)) {
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
            self.present(chatVC, animated: true, completion: nil)
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
            self.collectionView.reloadData()
        }
    }
}

extension DGStreamTabBarViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
