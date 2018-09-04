//
//  DGStreamNavigationController.swift
//  DGStream
//
//  Created by Brandon on 8/28/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func loadDetailFor(user: DGStreamUser) {
        
        guard let vc = UIStoryboard(name: "DetailPad", bundle: Bundle(identifier: "com.dataglance.DGStream")).instantiateInitialViewController() as? DGStreamDetailViewController else {
            return
        }
        
        vc.view.layoutIfNeeded()
        
        vc.load(user: user)
        
        self.pushViewController(vc, animated: true)
        
    }

}
