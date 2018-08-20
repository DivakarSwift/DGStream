//
//  DGStreamMediaViewController.swift
//  DGStream
//
//  Created by Brandon on 8/17/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamMediaViewController: UIViewController {

    @IBOutlet weak var navBarView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var showLocalLabel: UILabel!
    @IBOutlet weak var showLocalSwitch: UISwitch!
    @IBOutlet weak var tabBar: UIToolbar!
    @IBOutlet weak var addButtonItem: UIBarButtonItem!
    @IBOutlet weak var uploadButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteButtonItem: UIBarButtonItem!
    @IBOutlet weak var emptyLabel: UILabel!
    
    var isShare:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navBarView.backgroundColor = UIColor.dgBlueDark()
        
        if isShare {
            self.titleLabel.text = "Share"
            self.tabBar.isHidden = true
        }
        else {
            self.titleLabel.text = "Media"
        }
        
        self.setUpButtons()
    }
    
    func setUpButtons() {
        
        self.backButton.setTitleColor(.white, for: .normal)
        
        self.segmentedControl.addTarget(self, action: #selector(segmentedValueChanged), for: .valueChanged)
        self.segmentedControl.tintColor = .orange
        
        self.showLocalSwitch.tintColor = .orange
        
        self.addButtonItem.tintColor = .orange
        
        self.uploadButtonItem.tintColor = .orange
        self.uploadButtonItem.isEnabled = false
        self.deleteButtonItem.tintColor = .orange
        self.deleteButtonItem.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentedValueChanged() {
        let segment = self.segmentedControl.selectedSegmentIndex
        if segment == 0 {
            self.emptyLabel.text = "No Photos"
        }
        else if segment == 1 {
            self.emptyLabel.text = "No Videos"
        }
        else if segment == 2 {
            self.emptyLabel.text = "No Documents"
        }
    }
    
    @IBAction func showLocalValueChanged(_ sender: Any) {
        
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

}
