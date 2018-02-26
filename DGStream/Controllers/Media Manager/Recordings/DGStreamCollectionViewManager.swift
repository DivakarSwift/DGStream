//
//  DGStreamCollectionViewManager.swift
//  DGStream
//
//  Created by Brandon on 2/19/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import Foundation

class DGStreamCollectionViewManager:NSObject {
    
    var collectionView:UICollectionView!
    var transition = PopAnimator()
    
    let iPadPadding:CGFloat = 0
    let iPadNumberPerWidthLandscape:CGFloat = 0
    let iPadNumberPerWidthPortrait:CGFloat = 0
    
    let iPhonePadding:CGFloat = 0
    let iPhoneNumberPerWidthLandscape:CGFloat = 0
    let iPhoneNumberPerWidthPortrait:CGFloat = 0
    
    let duration:Double = 0.25
    
    func configureWith(collectionView: UICollectionView) {
        self.collectionView = collectionView
        self.collectionView.superview?.layer.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        print("ConfigureWithCollectionView")
        setLayoutForCollectionView()
    }
    
    func setLayoutForCollectionView() {
        print("setLayoutForCollectionView")
        if let collectionView = self.collectionView {
            if collectionView.tag == 0 {
                var cellPadding:CGFloat = 0
                var numberOfCells:CGFloat = 0
                if UIDevice.current.userInterfaceIdiom == .pad {
                    cellPadding = iPadPadding
                    if UIDevice.current.orientation.isLandscape {
                        numberOfCells = iPadNumberPerWidthLandscape
                    }
                    else {
                        numberOfCells = iPadNumberPerWidthPortrait
                    }
                }
                else {
                    cellPadding = iPhonePadding
                    if UIDevice.current.orientation.isLandscape {
                        numberOfCells = iPhoneNumberPerWidthLandscape
                    }
                    else {
                        numberOfCells = iPhoneNumberPerWidthPortrait
                    }
                }
                let screenWidth = UIScreen.main.bounds.width - (cellPadding * 2)
                let layout = UICollectionViewFlowLayout()
                
                let hw = (screenWidth / numberOfCells) - cellPadding
                let size = CGSize(width: hw, height: hw + 20)
                layout.itemSize = size
                layout.minimumInteritemSpacing = cellPadding
                layout.minimumLineSpacing = cellPadding
                layout.scrollDirection = .vertical
                layout.sectionInset = UIEdgeInsetsMake(cellPadding, cellPadding, 0, cellPadding)
                collectionView.setCollectionViewLayout(layout, animated: true, completion: { (finished) in
                    self.collectionView.isScrollEnabled = true
                    self.collectionView.isPagingEnabled = false
                    self.collectionView.alwaysBounceVertical = true
                    self.collectionView.bounces = true
                })
            }
        }
    }
    
    // MARK: - KVO
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration, execute: {
                self.setLayoutForCollectionView()
            })
        }
    }
    
    func removeObserver() {
        self.collectionView.superview?.layer.removeObserver(self, forKeyPath: "bounds")
    }
}

extension DGStreamCollectionViewManager: UICollectionViewDelegateFlowLayout {
    
}

extension DGStreamCollectionViewManager: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.presenting = false
        return transition
    }
}
