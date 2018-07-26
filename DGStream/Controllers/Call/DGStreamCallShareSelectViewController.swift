//
//  DGStreamCallShareSelectViewController.swift
//  DGStream
//
//  Created by Brandon on 6/6/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamCallShareSelectViewControllerDelegate {
    func callShareSelectViewControllerDidTapRecordings()
    func callShareSelectViewControllerDidTapPhotos()
    func callShareSelectViewControllerDidTapDocuments()
}

class DGStreamCallShareSelectViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var delegate: DGStreamCallShareSelectViewControllerDelegate!
    var options: [String] = ["Recordings", "Photos", "Documents"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension DGStreamCallShareSelectViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? DGStreamDropDownTableViewCell, let labelText = cell.label.text {
            if labelText == "Recordings" {
                self.delegate.callShareSelectViewControllerDidTapRecordings()
            }
            else if labelText == "Photos" {
                self.delegate.callShareSelectViewControllerDidTapPhotos()
            }
            else {
                self.delegate.callShareSelectViewControllerDidTapDocuments()
            }
        }
        dismiss(animated: false, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let option = self.options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamDropDownTableViewCell
        if indexPath.row == 0 {
            cell.seperator.alpha = 0
        }
        cell.label.font = UIFont(name: "HelveticaNeue-Bold", size: 18)
        cell.configureWith(title: option)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

