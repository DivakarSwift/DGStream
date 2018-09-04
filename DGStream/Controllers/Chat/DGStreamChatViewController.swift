//
//  DGStreamChatViewController.swift
//  DGStream
//
//  Created by Brandon on 10/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

protocol DGStreamChatViewControllerDelegate {
    func chat(viewController: DGStreamChatViewController, backButtonTapped sender:Any?)
    func chat(viewController: DGStreamChatViewController, tapped image:UIImage)
    func chat(viewController: DGStreamChatViewController, didReceiveMessage message: DGStreamMessage)
    func chatViewControllerDidFinishTakingPicture()
}


import UIKit
import Photos
import PhotosUI
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
    @IBOutlet weak var clearButton: UIButton!
    
    var chatConversation:DGStreamConversation!
    var isKeyboardShown = false
    var didLoadData = false
    var isInCall = true // set to false in TabVC
    
    var delegate: DGStreamChatViewControllerDelegate!
    
    let segmentedControlPadding:CGFloat = 10
    let segmentedControlHeight: CGFloat = 30
    var attachmentImage: UIImage?
    
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
        self.clearButton.setTitleColor(.white, for: .normal)
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
        if self.isInCall == false {
            DGStreamCore.instance.presentedViewController = self
        }
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

    func didReceive(message: QBChatMessage) {
        
        var shouldInformDelegate = false

        if let _ = chatConversation.userIDs.filter({ (userID) -> Bool in
            return userID.uintValue == message.senderID
        }).first {
            shouldInformDelegate = true
        }

        if shouldInformDelegate && self.view.alpha == 0 {
            DGStreamMessage.createReceivedMessageFrom(chatMessage: message) { (newMessage) in
                delegate.chat(viewController: self, didReceiveMessage: newMessage)
            }
        }
        
        if chatConversation.userIDs.contains(NSNumber.init(value: message.senderID)) {
            addReceivedChat(message: message)
        }
    }

    //MARK:- Button Actions
    @IBAction func backButtonTapped(_ sender: Any) {
        if chatConversation.type == .callConversation {
            delegate.chat(viewController: self, backButtonTapped: sender)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        self.activityIndicator.isHidden = true
        self.messengerView.removeMessagesWithBlock(self.messengerView.allMessages(), animation: .fade) {
            
        }
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        if let image = attachmentImage {
            sendChatMessageWith(text: nil, image: image)
        }
        else {
            sendChatMessageWith(text: textView.text, image: nil)
        }
    }

    @IBAction func photoButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "", message: "Choose Source", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action: UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                print("This device doesn't have a camera.")
                return
            }
            
            let message = QBChatMessage()
            message.recipientID = self.chatConversation.userIDs.filter({ (id) -> Bool in
                return id != DGStreamCore.instance.currentUser?.userID
            }).first?.uintValue ?? 0
            message.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            message.text = "takingPicture"
            DispatchQueue.global().async {
                let photoPicker = UIImagePickerController()
                photoPicker.sourceType = .camera
                photoPicker.delegate = self
                photoPicker.modalPresentationStyle = .custom
                DispatchQueue.main.async {
                    self.present(photoPicker, animated: false) {
                        QBChat.instance.sendSystemMessage(message, completion: { (error) in
                            
                        })
                    }
                }
            }
            
        }))
        alert.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action: UIAlertAction) in
            guard UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) else {
                print("This device doesn't have a camera.")
                let unavailableAlert = UIAlertController(title: "Unavailable", message: "This device does not have a compatible photo library.", preferredStyle: .actionSheet)
                unavailableAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                    unavailableAlert.dismiss(animated: true, completion: nil)
                }))
                self.present(unavailableAlert, animated: true, completion: nil)
                return
            }
            
            let message = QBChatMessage()
            message.recipientID = self.chatConversation.userIDs.filter({ (id) -> Bool in
                return id != DGStreamCore.instance.currentUser?.userID
            }).first?.uintValue ?? 0
            message.senderID = DGStreamCore.instance.currentUser?.userID?.uintValue ?? 0
            message.text = "takingPicture"
            
            self.checkPermission(completion: { (granted) in
                if granted {
                    let photoPicker = UIImagePickerController()
                    photoPicker.sourceType = .savedPhotosAlbum
                    photoPicker.delegate = self
                    photoPicker.modalPresentationStyle = .custom
                    self.present(photoPicker, animated: false) {
                        QBChat.instance.sendSystemMessage(message, completion: { (error) in
                            
                        })
                    }
                }
                else {
                    let permissionAlert = UIAlertController(title: "Unauthorized", message: "Change your device settings to allow eCollaborate permission to the device's photo library.", preferredStyle: .actionSheet)
                    permissionAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                        permissionAlert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(permissionAlert, animated: true, completion: nil)
                }
            })
            
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
    
    fileprivate func addReceivedChat(message: QBChatMessage) {
        // Turn back into Quickblox message
        let operation = DGStreamChatOperationQueue()
        // Create nodes for MessageView from message
        operation.getMessageNodesFor(messages: [message]) { (nodes) in
            // Add message
            DispatchQueue.main.async {
                self.messengerView.addMessages(nodes, scrollsToMessage: true)
            }
        }
    }

    fileprivate func addChat(message: DGStreamMessage) {
        // Turn back into Quickblox message
        DGStreamMessage.createQuickbloxMessageFrom(message: message) { (message) in
            if let message = message {
                let operation = DGStreamChatOperationQueue()
                // Create nodes for MessageView from message
                operation.getMessageNodesFor(messages: [message]) { (nodes) in
                    // Add message
                    DispatchQueue.main.async {
                        self.messengerView.addMessages(nodes, scrollsToMessage: true)
                    }
                }
            }
        }
        
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
        self.textView.attributedText = nil
        self.attachmentImage = nil
    }
    
}
    
extension DGStreamChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func checkPermission(completion:@escaping (_ success: Bool) -> Void) {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            completion(true)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                    completion(true)
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
            completion(false)
        case .denied:
            // same same
            print("User has denied the permission.")
            completion(false)
        }
    }
    @objc func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        defer {
            picker.dismiss(animated: false)
            self.delegate.chatViewControllerDidFinishTakingPicture()
        }
    }
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        defer {
            picker.dismiss(animated: false)
            self.delegate.chatViewControllerDidFinishTakingPicture()
        }
        
        print(info)
        // get the image
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        let newWidth = image.size.width / 2
        let newHeight = image.size.height / 2
        let thumbnailWidth = image.size.width / 4
        let thumbnailHeight = image.size.width / 4
        
        let smallerImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: newWidth, height: newHeight))
        let thumbnailImage = UIImage.resizeImage(image: image, targetSize: CGSize(width: thumbnailWidth, height: thumbnailHeight))
        
        // do something with it
        //self.sendChatMessageWith(text: nil, image: smallerImage)
        
        self.attachmentImage = smallerImage
        
        //let attributedString = NSMutableAttributedString(string: textView.text)
        let textAttachment = NSTextAttachment()
        textAttachment.image = thumbnailImage
        let oldWidth = textAttachment.image!.size.width;
        _ = oldWidth / (textView.frame.size.width - 10); //for the padding inside the textView
        let attrStringWithImage = NSAttributedString(attachment: textAttachment)
        //attributedString.replaceCharacters(in: NSMakeRange(textView.text.count, 1), with: attrStringWithImage)
        textView.text = ""
        textView.attributedText = nil
        textView.attributedText = attrStringWithImage
        textBarHeightConstraint.constant = 140
        self.sendButton.isEnabled = true
        self.sendButton.setTitleColor(.white, for: .normal)
    }
}

//MARK:- Messenger Delegate
extension DGStreamChatViewController: NMessengerDelegate {
    func didSelect(image: UIImage, frame: CGRect) {
//        let blackoutView = UIView(frame: UIScreen.main.bounds)
//        blackoutView.backgroundColor = .black
//        blackoutView.alpha = 0
//        self.view.addSubview(blackoutView)
//        let imageView = UIImageView(frame: frame)
//        imageView.backgroundColor = .clear
//        imageView.contentMode = .scaleAspectFit
//        imageView.image = image
//        imageView.clipsToBounds = true
//        self.view.addSubview(imageView)
//        UIView.animate(withDuration: 0.25, animations: {
//            imageView.frame = UIScreen.main.bounds
//            blackoutView.alpha = 1
//        }) { (f) in
//
//            DispatchQueue.main.async {
//                self.performSegue(withIdentifier: "image", sender: image)
//            }
//
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.10, execute: {
//                imageView.removeFromSuperview()
//                blackoutView.removeFromSuperview()
//            })
//
//        }
        DispatchQueue.main.async {
            if self.delegate == nil {
                self.performSegue(withIdentifier: "image", sender: image)
            }
            else {
                self.delegate.chat(viewController: self, tapped: image)
            }
        }
    }
    
    
}
    

