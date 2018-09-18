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
        
//        var storyboardName = "DetailPad"
//        if Display.phone {
//            storyboardName = "DetailPhone"
//        }
        
        self.maximumPrimaryColumnWidth = 375
        self.minimumPrimaryColumnWidth = 375
        
        self.showDetail()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(Ah), name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showDetail() {
        if self.viewControllers.count > 1, let detail = self.viewControllers[1] as? DGStreamDetailViewController {
            self.showDetailViewController(detail, sender: nil)
        }
    }

    func Ah() {
        if let alertString = DGStreamFileManager.checkForNewMedia() {
            
            let alert = UIAlertController(title: "New Media", message: alertString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action: UIAlertAction) in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

extension DGStreamSplitViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        if Display.phone {
            return false
        }
        return true
    }
}
