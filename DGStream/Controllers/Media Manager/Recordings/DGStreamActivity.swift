//
//  DGStreamActivity.swift
//  DGStream
//
//  Created by Brandon on 2/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamActivityDelegate {
    func didSelect(activity: DGStreamActivity)
}

protocol DGStreamActivityViewControllerDelegate {
    func activityViewControllerDidDismiss()
}

class DGStreamActivityViewController: UIActivityViewController {
    var delegate:DGStreamActivityViewControllerDelegate!
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delegate.activityViewControllerDidDismiss()
    }
}

class DGStreamActivity: UIActivity {
    
    var title: String!
    var image: UIImage?
    
    var type:UIActivityType!
    
    var delegate: DGStreamActivityDelegate!
    
    init(title: String, image: UIImage?, delegate: DGStreamActivityDelegate) {
        super.init()
        self.delegate = delegate
        self.image = image
        self.title = title
        type = UIActivityType(rawValue: title)
    }
    // this provides a way of excluding the activity if we wish
    override var activityType: UIActivityType {
        return self.type
    }
    
    override var activityTitle: String {
        return self.title
    }
    
    override var activityImage: UIImage? {
        return self.image
    }
    
    var activityCategory: UIActivityCategory {
        return .share
    }
    
    override func canPerform(withActivityItems activityItems: [Any]) -> Bool {
        return true
    }
    
    override func prepare(withActivityItems activityItems: [Any]) {
        
    }
    
    override func perform() {
        delegate.didSelect(activity: self)
    }
    
    class func getAllApplicationActivitiesFor(delegate: DGStreamActivityDelegate) -> [DGStreamActivity] {
        return [DGStreamActivity(title: "Sync", image: UIImage.init(named: "UploadCloud", in: Bundle(identifier: "com.dataglance.MediaManagerSDK"), compatibleWith: nil), delegate: delegate), DGStreamActivity(title: "CR", image: UIImage.init(named: "CR_Logo", in: Bundle(identifier: "com.dataglance.MediaManagerSDK"), compatibleWith: nil), delegate: delegate), DGStreamActivity(title: "AR", image: UIImage.init(named: "AR_Logo", in: Bundle(identifier: "com.dataglance.MediaManagerSDK"), compatibleWith: nil), delegate: delegate), DGStreamActivity(title: "WR", image: UIImage.init(named: "WR_Logo", in: Bundle(identifier: "com.dataglance.MediaManagerSDK"), compatibleWith: nil), delegate: delegate)]
    }
}

