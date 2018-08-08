//
//  DGStreamDetailViewController.swift
//  DGStream
//
//  Created by Brandon on 8/2/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("Detail Loaded")
        // Do any additional setup after loading the view.
        guard let split = self.splitViewController else {
            return
        }
        split.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DGStreamDetailViewController: UISplitViewControllerDelegate {
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController: UIViewController, onto primaryViewController: UIViewController) -> Bool {
        return true
    }
}
