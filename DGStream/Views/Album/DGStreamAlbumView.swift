//
//  DGStreamAlbumView.swift
//  DGStream
//
//  Created by Brandon on 2/20/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

//import UIKit

//protocol DGStreamAlbumViewDelegate {
//    func setTopMediaWith(_ media: MMSDKMedia)
//}

//public class DGStreamAlbumView: UICollectionView {
//
//    //var albumViewDelegate:DGStreamAlbumViewDelegate!
//    var dataSourceArray:[DGStreamRecording] = []
//
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        super.init(frame: frame, collectionViewLayout: layout)
//        register(MMAlbumViewCell.self, forCellWithReuseIdentifier: "AlbumCell")
//        self.dataSource = self
//        self.backgroundColor = UIColor.clear
//        self.isUserInteractionEnabled = false
//    }
//
//    required public init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//
//    func configureWith(collection: DGStreamRecordingCollection) {
//        if !collection.doesExistOnServer {
//            let media = createDGStreamRecordingFor(collection: collection)
//            var images:[UIImage] = []
//            for m in media {
//                if let thumbnail = m.thumbnail, let image = UIImage(data: thumbnail) {
//                    images.append(image)
//                }
//            }
//        }
//        else if let thumbnailURL = collection.thumbnailURL, let url = URL.init(string: thumbnailURL) {
//            DispatchQueue.global().async {
//                let data = try? Data.init(contentsOf: url)
//                if let data = data {
//                    let media = DGStreamRecording()
//                    if let image = UIImage(data: data) {
//                        media.thumbnail = UIImageJPEGRepresentation(image, 1.0)
//                    }
//                    DispatchQueue.main.async {
//                        self.dataSourceArray.append(media)
//                    }
//                }
//            }
//        }
//    }
//
//}
//
//extension DGStreamAlbumView: UICollectionViewDataSource {
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return dataSourceArray.count
//    }
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if indexPath.item == 0 {
//            self.albumViewDelegate.setTopMediaWith(dataSourceArray[0])
//        }
//        let cell:MMAlbumViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! MMAlbumViewCell
//        cell.configureWith(media: dataSourceArray[indexPath.row])
//        return cell
//    }
//    func nextViewControllerAtPoint(p: CGPoint) -> UICollectionViewController? {
//        return nil
//    }
//}

