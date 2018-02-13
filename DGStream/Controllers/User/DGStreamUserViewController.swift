//
//  DGStreamUserViewController.swift
//  DGStream
//
//  Created by Brandon on 12/19/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

class DGStreamUserViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navBarView: UIView!
    
    @IBOutlet weak var backButton: UIButton!
    
    var user: DGStreamUser!
    
    var recents: [DGStreamRecent] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        self.backButton.setTitle(NSLocalizedString("Back", bundle: Bundle(identifier: "DGStream")!, comment: "Return to previous screen"), for: .normal)
        self.backButton.setTitleColor(.white, for: .normal)
        
        loadRecents()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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

extension DGStreamUserViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 160
        }
        else {
            return 70
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 40
        }
        return 0
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: 40))
            label.backgroundColor = UIColor.dgBlueDark()
            label.text = NSLocalizedString("Recent Activity", bundle: Bundle(identifier: "DGStream")!, comment: "")
            label.textAlignment = .center
            label.textColor = .white
            label.font = UIFont(name: "HelveticaNeue-Bold", size: 22)
            return label
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
