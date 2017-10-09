//
//  DGStreamUsersViewController.swift
//  DGStream
//
//  Created by Brandon on 9/13/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC

class DGStreamUsersViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        DGStreamCore.instance.presentedViewController = self
        DGStreamCore.instance.add(delegate: self)
        QBRTCClient.instance().add(self)
        configureTableView()
        configureNavBar()
        
        if let user = DGStreamCore.instance.currentUser {
            DGStreamCore.instance.loginWith(user: user) { (success, errorMessage) in
                
                if success {
                    UIApplication.shared.registerForRemoteNotifications()
                    self.loadUsers()
                }
                else {
                    let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        self.navigationController?.navigationBar.barTintColor = UIColor.dgBlueDark()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationItem.setLeftBarButton(UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(cancelButtonTapped)), animated: false)
        
        let audioButton = UIBarButtonItem(title: "Audio Call", style: .plain, target: self, action: #selector(audioCallButtonTapped))
        
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: self, action: nil)
        fixedSpace.width = 20
        
        let videoButton = UIBarButtonItem(title: "Video Call", style: .plain, target: self, action: #selector(videoCallButtonTapped))
        
        self.navigationItem.setRightBarButtonItems([audioButton, fixedSpace, videoButton], animated: true)
    }
    
    func configureTableView() {
        DGStreamCore.instance.userDataSource = DGStreamUserDataSource(currentUser: DGStreamCore.instance.currentUser)
        self.tableView.dataSource = DGStreamCore.instance.userDataSource
        self.tableView.delegate = self
        self.tableView.rowHeight = 60
    }

    func loadUsers() {
        self.tableView.isHidden = true
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        if DGStreamCore.instance.isReachable {
            DGStreamUserOperationQueue().getUsersWith(tags: ["dev"]) { (success, errorMessage, users) in
                if success {
                    if let dataSource = DGStreamCore.instance.userDataSource, dataSource.set(users: users) {
                        self.tableView.reloadData()
                        self.tableView.isHidden = false
                    }
                }
                else {
                    let alert = UIAlertController(title: "User Download Error", message: errorMessage, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in
                        alert.dismiss(animated: true, completion: nil)
                    }))
                }
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    func cancelButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    func audioCallButtonTapped() {
        callSelectedUsersWith(type: .audio)
    }
    
    func videoCallButtonTapped() {
        callSelectedUsersWith(type: .video)
        print("videoCallButtonTapped")
    }
    
    func callSelectedUsersWith(type: QBRTCConferenceType) {
        
        if DGStreamCore.instance.isReachable {
            
            let userIDs = DGStreamCore.instance.userDataSource?.idsFor(users: DGStreamCore.instance.userDataSource?.selectedUsers ?? [])
            
            let session = QBRTCClient.instance().createNewSession(withOpponents: userIDs ?? [], with: type)
            
            let callVC = UIStoryboard(name: "Call", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as! DGStreamCallViewController
            callVC.session = session
            
            let nav = UINavigationController(rootViewController: callVC)
            nav.modalTransitionStyle = .crossDissolve
            
            present(nav, animated: true, completion: nil)
            print("This is the comment that will need to be seen")
        }
        
    }

}

extension DGStreamUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DGStreamCore.instance.userDataSource?.selectUserAt(indexPath: indexPath)
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        label.backgroundColor = .white
        label.textColor = UIColor.dgBlack()
        label.text = "    Select Users To Call..."
        label.font = UIFont.dgBasicFont()
        return label
    }
}

extension DGStreamUsersViewController: QBRTCClientDelegate {
    
}
