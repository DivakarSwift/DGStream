//
//  DGStreamChatNavigationController.swift
//  DGStream
//
//  Created by Brandon on 11/21/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamChatNavigationController: UIViewController {

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var abrevLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var messengerContainer: UIView!
    var chatConversation:DGStreamConversation!
    var selectedUser:DGStreamUser?
    var callVC:DGStreamCallViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        self.backButton.setTitleColor(.white, for: .normal)
        
        let vc = UIStoryboard(name: "Chat", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateViewController(withIdentifier: "Chat") as! DGStreamChatViewController
        vc.chatConversation = self.chatConversation
        vc.delegate = self.callVC
        
        vc.didMove(toParentViewController: self)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
    }
    
}
