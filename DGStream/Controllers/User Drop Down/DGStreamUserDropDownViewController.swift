//
//  DGStreamUserDropDownViewController.swift
//  DGStream
//
//  Created by Brandon on 12/29/17.
//  Copyright © 2017 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamUserDropDownViewControllerDelegate {
    func logoutTapped()
    func userButtonTapped()
}

class DGStreamUserDropDownViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var titles:[String] = []
    var delegate: DGStreamUserDropDownViewControllerDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.isModalInPopover = false
        
        titles.append("Logout")

        // Do any additional setup after loading the view.
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension DGStreamUserDropDownViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        self.delegate.logoutTapped()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamDropDownTableViewCell
        cell.configureWith(title: self.titles[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let userHeader = UINib(nibName: "UserHeader", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiate(withOwner: self, options: nil).first as? DGStreamUserHeader, let currentUser = DGStreamCore.instance.currentUser {
            userHeader.configureWith(user: currentUser)
            return userHeader
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 150
    }
}
