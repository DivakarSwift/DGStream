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
    
    var chatConversation:DGStreamConversation!
    var isKeyboardShown = false
    var didLoadData = false
    
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
        
        self.photoButton.setImage(UIImage.init(named: "capture", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        self.photoButton.tintColor = .white

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow), name: Notification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame(notification:)), name: Notification.Name.UIKeyboardWillChangeFrame, object: nil)

        self.messengerView = NMessenger(frame: self.messengerContainer.bounds)
        self.messengerView.boundInside(container: self.messengerContainer)
        self.messengerView.delegate = self
        
        self.activityIndicator.color = UIColor.dgBlack()
        self.activityIndicator.startAnimating()
        self.view.bringSubview(toFront: self.activityIndicator)
    }

    override public func viewWillAppear(_ animated: Bool) {
        DGStreamCore.instance.presentedViewController = self
        if didLoadData == false {
            loadData()
        }
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "image",
            let image = sender as? UIImage,
            let imageVC = segue.destination as? DGStreamChatImageViewController {
            imageVC.image = image
        }
    }
    
    func loadData() {
        print("LOAD DATA")
        didLoadData = true
        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID {
            for userID in self.chatConversation.userIDs {
                if userID != currentUserID, let user = DGStreamCore.instance.getOtherUserWith(userID: userID), let username = user.username {
                    
                    self.nameLabel.text = username
                    
                    if let imageData = user.image, let image = UIImage(data: imageData) {
                        self.imageView.image = image
                    }
                    else {
                        let abrev = NSString(string: username).substring(to: 1)
                        self.abrevLabel.text = abrev
                    }
                    
                    break
                }
            }
        }
        DGStreamCore.instance.chatViewController = self
        loadMessages()
    }

    func loadMessages() {
        
        print("Load Messages")

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
                    
                }, errorBlock: { (errorResponse) in
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                })

            }
            else {
                // Can not ping server, update UI
//                let alert = UIAlertController(title: "COULD NOT PING SERVER", message: "CurrentUser: \(DGStreamCore.instance.currentUser != nil)", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
//                    alert.dismiss(animated: true, completion: nil)
//                }))
//                self.present(alert, animated: true, completion: nil)
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
        sendChatMessageWith(text: textView.text, image: nil)
    }

    @IBAction func photoButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: "Choose Source", preferredStyle: .actionSheet)
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
        alert.popoverPresentationController?.sourceView = self.view
        alert.popoverPresentationController?.sourceRect = CGRect(x: 20, y: self.textBar.frame.origin.y, width: 20, height: 20)
        self.present(alert, animated: true) {
            
        }
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
//extension DGStreamChatViewController: UITableViewDataSource {
//    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return chatMessages.count
//    }
//    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        var cellIdentifier:String = ""
//        let chatMessage = chatMessages[indexPath.row]
//
//        if let currentUser = DGStreamCore.instance.currentUser, let currentUserID = currentUser.userID, chatMessage.senderID == currentUserID {
//            cellIdentifier = "SelfCell"
//        }
//        else {
//            cellIdentifier = "Cell"
//        }
//
//            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! DGStreamChatTableViewCell
//            cell.configureWith(chatMessage: chatMessage)
//            return cell
//        }
//    }

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
            sendChatMessageWith(text: textView.text, image: nil)
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
        
        if isIncomingMessage {
            // Play Incoming Sound
        }
        else {
            // Play Outgoing Sound
        }
        
        var messageNode: MessageNode!

        if let image = message.image {
            let imageNode = ImageContentNode(image: image, bubbleConfiguration: DGStreamChatBubble() as BubbleConfigurationProtocol)
            imageNode.bubbleConfiguration = DGStreamChatImageBubble() as BubbleConfigurationProtocol
            messageNode = MessageNode(content: imageNode)
        }
        else {
            let textNode = TextContentNode(textMessageString: message.message)
            textNode.isIncomingMessage = isIncomingMessage
            textNode.incomingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.outgoingTextFont = UIFont(name: "HelveticaNeue-Bold", size: 14)!
            textNode.insets = UIEdgeInsetsMake(8, 8, 8, 8)
            textNode.incomingTextColor = .white
            textNode.bubbleConfiguration = DGStreamChatBubble() as BubbleConfigurationProtocol
            messageNode = MessageNode(content: textNode)
        }

        messageNode.isIncomingMessage = isIncomingMessage
        messageNode.messageOffset = 10
        messageNode.cellPadding = UIEdgeInsetsMake(5, 0, 5, 0)

        self.messengerView.addMessage(messageNode, scrollsToMessage: true)
    }

    fileprivate func addChat(messages: [QBChatMessage]) {
        let chatOperationQueue = DGStreamChatOperationQueue()
        chatOperationQueue.getMessageNodesFor(messages: messages) { (messageNodes) in
            DispatchQueue.main.async {
                self.messengerView.addMessages(messageNodes, scrollsToMessage: false)
                self.messengerView.scrollToLastMessage(animated: false)
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }

    func sendChatMessageWith(text: String?, image: UIImage?) {
        self.textView.resignFirstResponder()
        self.sendButton.isEnabled = false
        self.sendButton.setTitleColor(.lightGray, for: .normal)

        if let user = DGStreamCore.instance.currentUser, let currentUserID = user.userID {

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
            chatMessage.image = image
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
    
extension DGStreamChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: true)
        }
        
        print(info)
        // get the image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let newWidth = image.size.width / 2
        let newHeight = image.size.height / 2
        
        let smallerImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: newWidth, height: newHeight))
        
        // do something with it
        self.sendChatMessageWith(text: nil, image: smallerImage)
        
    }
}

//MARK:- Messenger Delegate
extension DGStreamChatViewController: NMessengerDelegate {
    func didSelect(image: UIImage, frame: CGRect) {
        let blackoutView = UIView(frame: UIScreen.main.bounds)
        blackoutView.backgroundColor = .black
        blackoutView.alpha = 0
        self.view.addSubview(blackoutView)
        let imageView = UIImageView(frame: frame)
        imageView.backgroundColor = .clear
        imageView.contentMode = .scaleAspectFit
        imageView.image = image
        imageView.clipsToBounds = true
        self.view.addSubview(imageView)
        UIView.animate(withDuration: 0.25, animations: {
            imageView.frame = UIScreen.main.bounds
            blackoutView.alpha = 1
        }) { (f) in
            
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "image", sender: image)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
                imageView.removeFromSuperview()
                blackoutView.removeFromSuperview()
            })
            
        }
    }
    
    
}
    

