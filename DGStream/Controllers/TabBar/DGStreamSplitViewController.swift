//
//  DGStreamSplitViewController.swift
//  DGStream
//
//  Created by Brandon on 8/9/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamSplitViewController: UISplitViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self
        
        var storyboardName = "DetailPad"
        if Display.phone {
            storyboardName = "DetailPhone"
        }
        
        self.maximumPrimaryColumnWidth = 380
        self.minimumPrimaryColumnWidth = 320

        if let vc = UIStoryboard(name: storyboardName, bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() {
            self.showDetailViewController(vc, sender: nil)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

extension DGStreamSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
