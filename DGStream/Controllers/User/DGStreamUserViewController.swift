//
//  DGStreamUserViewController.swift
//  DGStream
//
//  Created by Brandon on 12/19/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

enum CommnicationType {
    case video
    case audio
    case message
}

protocol DGStreamUserViewControllerDelegate {
    func userViewController(_ vc: DGStreamUserViewController, didTap: CommnicationType, forUserID userID: NSNumber)
}

class DGStreamUserViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    
    var user: DGStreamUser!
    var userID: NSNumber!
    var recents: [DGStreamRecent] = []
    var isFavorite:Bool = false
    var delegate: DGStreamUserViewControllerDelegate!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        if let userID = user.userID {
            self.userID = userID
            if DGStreamCore.instance.isFavorite(userID: userID) {
                self.favoriteButton.setTitle("Remove Favorite", for: .normal)
                self.isFavorite = true
            }
        }
        
        self.navBarView.backgroundColor = .white
        self.backButton.setTitle(NSLocalizedString("Back", comment: "Return to previous screen"), for: .normal)
        self.backButton.setTitleColor(UIColor.dgButtonColor(), for: .normal)
        self.tableView.backgroundColor = .clear
        self.tableView.backgroundView?.backgroundColor = .clear
        self.backgroundImageView.image = UIImage(named: "background", in: Bundle(identifier: "com.dataglance.DGStream"), compatibleWith: nil)
        loadRecents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        if let nav = self.navigationController {
            nav.popViewController(animated: true)
        }
        else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if self.isFavorite {
            DGStreamCore.instance.removeFavorite(userID: self.userID)
            self.isFavorite = false
            self.favoriteButton.setTitle("Add Favorite", for: .normal)
        }
        else {
            DGStreamCore.instance.addFavorite(userID: self.userID)
            self.isFavorite = true
            self.favoriteButton.setTitle("Remove Favorite", for: .normal)
        }
    }
    
    //MARK:- Load Data
    func loadRecents() {
        if let currentUser = DGStreamCore.instance.currentUser,
            let currentUserID = currentUser.userID,
            let userID = self.user.userID {
            self.recents = DGStreamRecent.createDGStreamRecentsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recentsWithUserIDs: [currentUserID, userID]))
            print("Loadded Recents \(self.recents.count)")
            if self.recents.count == 0 {
//                self.emptyLabel.text = "No Recents"
//                self.emptyLabel.alpha = 1
            }
        }
        self.tableView.reloadData()
    }

}

extension DGStreamUserViewController: DGStreamUserHeaderDelegate {
    func close() {
        if let nav = self.navigationController {
            nav.popViewController(animated: false)
        }
        else {
            self.dismiss(animated: false, completion: nil)
        }
    }
    func userImageButtonTapped() {
        
    }
    
    func didTapVideoCall() {
        self.close()
        self.delegate.userViewController(self, didTap: .video, forUserID: self.userID)
    }
    
    func didTapAudioCall() {
        self.close()
        self.delegate.userViewController(self, didTap: .audio, forUserID: self.userID)
    }
    
    func didTapMessage() {
        self.close()
        self.delegate.userViewController(self, didTap: .message, forUserID: self.userID)
    }
    
    
}

extension DGStreamUserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 240
        }
        else {
            return 76
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 0.5
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
            view.backgroundColor = UIColor.dgBlack()
            return view
        }
        return nil
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        else {
           return self.recents.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0, let userHeader = UINib(nibName: "UserHeader", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamUserHeader {
            userHeader.configureWith(user: self.user)
            userHeader.delegate = self
            let cell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")!
            userHeader.boundInside(container: cell.contentView)
            return cell
        }
        else {
            
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell") as! DGStreamUserTableViewCell
        cell.configureWith(recent: self.recents[indexPath.row])
        return cell
    }
}
