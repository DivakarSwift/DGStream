//
//  DGStreamChatImageViewController.swift
//  DGStream
//
//  Created by Brandon on 3/8/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamChatImageViewController: UIViewController {
    
    @IBOutlet weak var backButton: UIButton!
    var image: UIImage!
  
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = self.image
        //self.scrollView.contentSize = UIScreen.main.bounds.size
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        NotificationCenter.default.removeObserver(self, name: Notification.Name.UIDeviceOrientationDidChange, object: nil)
        self.dismiss(animated: false, completion: nil)
    }
    
    func orientationWillChange(notification: Notification) {
//        self.scrollView.contentSize = UIScreen.main.bounds.size
//        self.scrollView.zoom(to: UIScreen.main.bounds, animated: true)
    }

}

extension DGStreamChatImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
}
