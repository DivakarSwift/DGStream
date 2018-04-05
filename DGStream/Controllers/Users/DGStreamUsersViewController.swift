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
    
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var navTitleLabel: UILabel!
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var selectedUsers:[NSNumber] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioCallButton.setImage(UIImage.init(named: "audio", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        audioCallButton.tintColor = UIColor.dgBlack()
        audioCallButton.layer.cornerRadius = audioCallButton.frame.size.width / 2
        audioCallButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        audioCallButton.backgroundColor = UIColor(red: (30/255.0), green: (220/255.0), blue: (35/255.0), alpha: 1)
        audioCallButton.addTarget(self, action: #selector(audioCallButtonTapped), for: .touchUpInside)
        
        videoCallButton.setImage(UIImage.init(named: "video", in: Bundle.init(identifier: "com.dataglance.DGStream"), compatibleWith: nil)?.withRenderingMode(.alwaysTemplate), for: .normal)
        videoCallButton.tintColor = UIColor.dgBlack()
        videoCallButton.layer.cornerRadius = videoCallButton.frame.size.width / 2
        videoCallButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        videoCallButton.backgroundColor = UIColor(red: (30/255.0), green: (220/255.0), blue: (35/255.0), alpha: 1)
        videoCallButton.addTarget(self, action: #selector(videoCallButtonTapped), for: .touchUpInside)
        
        view.backgroundColor = UIColor.dgWhite()
        DGStreamCore.instance.presentedViewController = self
        DGStreamCore.instance.add(delegate: self)
        QBRTCClient.instance().add(self)
        configureTableView()
        configureNavBar()
        loadUsers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DGStreamCore.instance.presentedViewController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func configureNavBar() {
        
        self.navBarView.backgroundColor = UIColor.dgBlack()
        self.navTitleLabel.textColor = UIColor.dgWhite()
    }
    
    func configureTableView() {
        if let currentUser = DGStreamCore.instance.currentUser {
            DGStreamCore.instance.userDataSource = DGStreamUserDataSource(currentUser: currentUser)
            self.tableView.dataSource = DGStreamCore.instance.userDataSource
            self.tableView.delegate = self
            self.tableView.rowHeight = 60
            self.tableView.backgroundColor = .clear
            self.tableView.backgroundView?.backgroundColor = .clear
        }
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
        //callSelectedUsersWith(type: .audio)
    }
    
    func videoCallButtonTapped() {
        //callSelectedUsersWith(type: .video)
        print("videoCallButtonTapped")
    }

}

extension DGStreamUsersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let userID = DGStreamCore.instance.userDataSource?.selectUserAt(indexPath: indexPath), let cell = self.tableView.cellForRow(at: indexPath) as? DGStreamUserTableViewCell {
                
            // Remove / Add
            if let idx = selectedUsers.index(of: userID) {
                selectedUsers.remove(at: idx)
//                cell.selectedIndex = 0
//                cell.selectedNumberLabel.text = ""
//                cell.selectedNumberLabel.isHidden = true
            }
            else {
                selectedUsers.append(userID)
                let count = selectedUsers.count
//                cell.selectedIndex = count
//                cell.selectedNumberLabel.text = "\(count)"
//                cell.selectedNumberLabel.isHidden = false
            }
            
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 320, height: 30))
        label.backgroundColor = UIColor.dgWhite()
        label.textColor = UIColor.dgBlack()
        label.text = "    Select Users To Call..."
        label.font = UIFont.dgBasicFont()
        return label
    }
}

extension DGStreamUsersViewController: QBRTCClientDelegate {
    
}
