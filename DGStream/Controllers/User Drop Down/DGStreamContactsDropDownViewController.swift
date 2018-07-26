//
//  DGStreamContactsDropDownViewController.swift
//  DGStream
//
//  Created by Brandon on 5/29/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

enum ContactsDropDownOption: String {
    case allContacts = "All Contacts"
    case experts = "Experts"
    case favorites = "Favorites"
}

protocol DGStreamContactsDropDownViewControllerDelegate {
    func contactsDropdown(_ dropDown: DGStreamContactsDropDownViewController, didTap: ContactsDropDownOption)
}

class DGStreamContactsDropDownViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: DGStreamContactsDropDownViewControllerDelegate!
    var selectedOption: ContactsDropDownOption!
    var options: [ContactsDropDownOption] = [.allContacts, .experts, .favorites]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let index = self.options.index(of: self.selectedOption) {
            self.options.remove(at: index)
        }
        
        self.tableView.reloadData()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DGStreamContactsDropDownViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DGStreamDropDownTableViewCell, let labelText = cell.label.text {
            if labelText == "All Contacts" {
                self.delegate.contactsDropdown(self, didTap: .allContacts)
            }
            else if labelText == "Experts" {
                self.delegate.contactsDropdown(self, didTap: .experts)
            }
            else {
                self.delegate.contactsDropdown(self, didTap: .favorites)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = self.options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamDropDownTableViewCell
        if indexPath.row == 0 {
            cell.seperator.alpha = 0
        }
        cell.label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        cell.configureWith(title: option.rawValue)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
