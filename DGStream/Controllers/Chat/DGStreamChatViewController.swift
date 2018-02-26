//
//  DGStreamChatViewController.swift
//  DGStream
//
//  Created by Brandon on 10/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

protocol DGStreamChatViewControllerDelegate {
    func chat(viewController: DGStreamChatViewController, backButtonTapped sender:Any?)
    func chat(viewController: DGStreamChatViewController, didReceiveMessage message: DGStreamMessage)
}


import UIKit
import NMessenger

class DGStreamChatViewController: UIViewController {
    
    @IBOutlet weak var textBar: UIView!
    @IBOutlet weak var textBarHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var messengerContainerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var photoButton: UIButton!
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var messengerView:NMessenger!
    @IBOutlet weak var messengerContainer: UIView!
    
    var chatMessages:[DGStreamMessage] = []
    var chatConversation:DGStreamConversation!
    var isKeyboardShown = false
    
    var delegate: DGStreamChatViewControllerDelegate!
    
    let segmentedControlPadding:CGFloat = 10
    let segmentedControlHeight: CGFloat = 30
    
    lazy var senderSegmentedControl : UISegmentedControl = {
        let control = UISegmentedControl(items: ["incoming", "outgoing"])
        control.selectedSegmentIndex = 0
        return control
    }()
    
    private(set) var lastMessageGroup:MessageGroup? = nil
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.dgBackground()

        // Nav Bar
        self.navBarView.backgroundColor = UIColor.dgDarkGray()
        self.imageView.layer.cornerRadius = self.imageView.frame.size.width / 2
        self.imageView.backgroundColor = UIColor.dgBackground()
        self.backButton.setTitleColor(.white, for: .normal)
        self.nameLabel.textColor = UIColor.dgBackground()
        self.abrevLabel.textColor = UIColor.dgDarkGray()

        // Text Bar
        self.textBar.backgroundColor = UIColor.dgDarkGray()
        self.textView.textContainerInset = UIEdgeInsetsMake(5, 10, 0, 10)
        self.textView.layer.cornerRadius = self.textView.frame.size.height / 2
        self.textView.layer.borderColor = UIColor.dgBlack().cgColor
        self.textView.layer.borderWidth = 0.5
        self.textView.textColor = UIColor.lightGray
        self.sendButton.setTitleColor(.lightGray, for: .normal)
        self.sendButton.isEnabled = false

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

        self.messengerView = NMessenger(frame: self.messengerContainer.bounds)
        self.messengerView.boundInside(container: self.messengerContainer)
        
        self.activityIndicator.color = UIColor.dgBlack()
        self.activityIndicator.startAnimating()
        self.view.bringSubview(toFront: self.activityIndicator)
    }

    override public func viewWillAppear(_ animated: Bool) {
        loadData()
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func loadData() {
        print("LOAD DATA")
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            for userID in self.chatConversation.userIDs {
                if userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
                    let abrev = NSString(string: username).substring(to: 1)
                    self.abrevLabel.text = abrev
                    self.nameLabel.text = username
                    break
                }
            }
        }
        DGStreamCore.instance.chatViewController = self
        loadMessages()
    }

    func loadMessages() {

        let dialogID = self.chatConversation.conversationID!

        QBChat.instance.pingServer(withTimeout: 2.0) { (interval, success) in
            if success {
                // We have connection to the server. Get the messages for this dialog
                let page = QBResponsePage(limit: 200, skip: 0)
                
                let extendedRequest = ["sort_asc" : "created_at"]
                
                QBRequest.messages(withDialogID: dialogID, extendedRequest: extendedRequest, for: page, successBlock: { (response, messages, responsePage) in
                    
                    if response.isSuccess {
                        self.addChat(messages: messages)
                    }
                    
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    
                }, errorBlock: { (errorResponse) in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                })

            }
            else {
                // Can not ping server, update UI
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func didReceive(message: DGStreamMessage) {

        var shouldInformDelegate = false

        if let senderID = message.senderID, let _ = chatConversation.userIDs.filter({ (userID) -> Bool in
            return userID == senderID
        }).first {
            shouldInformDelegate = true
        }

        if shouldInformDelegate && self.view.alpha == 0 {
            delegate.chat(viewController: self, didReceiveMessage: message)
        }
        if chatConversation.conversationID == message.conversationID {
            addChat(message: message)
        }
    }

    //MARK:- Button Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        if chatConversation.type == .callConversation {
            delegate.chat(viewController: self, backButtonTapped: sender)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        sendChatMessageWith(text: textView.text)
    }

    @IBAction func photoButtonTapped(_ sender: Any) {

    }

    @IBAction func moreButtonTapped(_ sender: Any) {

    }


}

// MARK:- UIKeyboard
extension DGStreamChatViewController {

    func keyboardWillShow(notification: Notification) {
        if let info = notification.userInfo, let frame = info[UIKeyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = frame.height
            let textBarHeight:CGFloat = 88
            let bottomPadding:CGFloat = 34

            var duration:Double = 0.25
            if let keyboardAnimationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                duration = keyboardAnimationDuration
            }

            var options = UIViewAnimationOptions.init(rawValue: 7)
            if let keyboardAnimationCurve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                options = UIViewAnimationOptions.init(rawValue: keyboardAnimationCurve)
            }

            textBarBottomConstraint.constant = keyboardHeight
            textBarHeightConstraint.constant = textBarHeight
            messengerContainerBottomConstraint.constant += keyboardHeight + bottomPadding

            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.view.layoutIfNeeded()
                self.messengerView.scrollToLastMessage(animated: true)
            }, completion: { (f) in
                
            })
        }
    }

    func keyboardDidShow() {
        isKeyboardShown = true
    }

    func keyboardWillHide(notification: Notification) {

        isKeyboardShown = false

        if let info = notification.userInfo {

            let textBarHeight:CGFloat = 50
            let keyboardHeight:CGFloat = 0

            var duration:Double = 0.25
            if let keyboardAnimationDuration = info[UIKeyboardAnimationDurationUserInfoKey] as? Double {
                duration = keyboardAnimationDuration
            }

            var options = UIViewAnimationOptions.init(rawValue: 7)
            if let keyboardAnimationCurve = info[UIKeyboardAnimationCurveUserInfoKey] as? UInt {
                options = UIViewAnimationOptions.init(rawValue: keyboardAnimationCurve)
            }

            textBarBottomConstraint.constant = keyboardHeight
            textBarHeightConstraint.constant = textBarHeight
            messengerContainerBottomConstraint.constant = textBarHeight
            
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (f) in
                self.messengerView.scrollToLastMessage(animated: true)
            })

        }
    }

    func keyboardWillChangeFrame(notification: Notification) {
        if isKeyboardShown, let info = notification.userInfo, let frame = info["UIKeyboardFrameEndUserInfoKey"] as? CGRect {
            let keyboardHeight = frame.height
            textBarBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        }
    }


}

// MARK:- UITableView
extension DGStreamChatViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        var cellIdentifier:String = ""
        let chatMessage = chatMessages[indexPath.row]

        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, chatMessage.senderID == currentUserID {
            cellIdentifier = "SelfCell"
        }
        else {
            cellIdentifier = "Cell"
        }

            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DGStreamChatTableViewCell
            cell.configureWith(chatMessage: chatMessage)
            return cell
        }
    }

// MARK:- UITextViewDelegate
extension DGStreamChatViewController: UITextViewDelegate {

    public func textViewDidBeginEditing(_ textView: UITextView) {
        textView.textColor = UIColor.darkGray
        textView.text = ""
    }

    public func textViewDidEndEditing(_ textView: UITextView) {
        
    }

    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            sendChatMessageWith(text: textView.text)
            return false
        }
        else {
            self.sendButton.setTitleColor(.white, for: .normal)
            self.sendButton.isEnabled = true
        }
        return true
    }

    fileprivate func addChat(message: DGStreamMessage) {

        var isIncomingMessage:Bool = true
        if let user = DGStreamCore.instance.currentUser, let currentUserID = user.userID, message.senderID == currentUserID {
            isIncomingMessage = false
        }

        let textNode = TextContentNode(textMessageString: message.message)
        textNode.isIncomingMessage = isIncomingMessage
        textNode.incomingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
        textNode.outgoingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
        textNode.insets = UIEdgeInsetsMake(8, 8, 8, 8)
        textNode.incomingTextColor = .white

        if isIncomingMessage {
            // Play Incoming Sound
        }
        else {
            // Play Outgoing Sound
        }

        textNode.bubbleConfiguration = DGStreamChatBubble() as BubbleConfigurationProtocol

        let messageNode = MessageNode(content: textNode)
        messageNode.isIncomingMessage = isIncomingMessage
        messageNode.messageOffset = 10
        messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)

        self.messengerView.addMessage(messageNode, scrollsToMessage: true)
    }

    fileprivate func addChat(messages: [QBChatMessage]) {

        var messageNodes:[MessageNode] = []

        for message in messages {
            var isIncomingMessage:Bool = true
            if let user = DGStreamCore.instance.currentUser, let currentUserID = user.userID, message.senderID == currentUserID.uintValue {
                isIncomingMessage = false
            }

            let textNode = TextContentNode(textMessageString: message.text ?? "")
            textNode.isIncomingMessage = isIncomingMessage
            textNode.incomingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.outgoingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.insets = UIEdgeInsetsMake(8, 8, 8, 8)
            textNode.incomingTextColor = .white
            textNode.bubbleConfiguration = DGStreamChatBubble()

            let messageNode = MessageNode(content: textNode)
            messageNode.isIncomingMessage = isIncomingMessage
            messageNode.messageOffset = 10
            messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)

            messageNodes.append(messageNode)
        }

        self.messengerView.addMessages(messageNodes, scrollsToMessage: false)
        self.messengerView.scrollToLastMessage(animated: false)
    }

    func sendChatMessageWith(text: String) {
        self.textView.resignFirstResponder()
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(.lightGray, for: .normal)

        if let user = DGStreamCore.instance.currentUser, let currentUserID = user.userID, !self.textView.text.isEmpty {

            var receivers: [NSNumber] = []
            if let userIDs = self.chatConversation.userIDs {
                for id in userIDs {
                    if id != currentUserID {
                        receivers.append(id)
                    }
                }
            }

            let chatMessage = DGStreamMessage()
            chatMessage.delivered = Date()
            chatMessage.message = text
            chatMessage.senderID = currentUserID
            chatMessage.receiverID = receivers.first
            chatMessage.conversationID = self.chatConversation.conversationID
            for receiverID in receivers {
                chatMessage.receiverID = receiverID
                DGStreamCore.instance.sendChat(message: chatMessage)
            }
            addChat(message: chatMessage)
        }
        
        self.textView.text = ""
    }
    
}
    
    
    
    

