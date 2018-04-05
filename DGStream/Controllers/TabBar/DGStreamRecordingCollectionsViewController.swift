//
//  DGStreamRecordingCollectionsViewController.swift
//  DGStream
//
//  Created by Brandon on 2/21/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

class DGStreamRecordingCollectionsViewController: UIViewController {
    
    @IBOutlet weak var navBarBackButton: UIButton!
    @IBOutlet weak var navBarTitle: UILabel!
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var tableView: UITableView!
    var collections: [DGStreamRecordingCollection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navBar.backgroundColor = UIColor.dgBlueDark()
        self.navBarTitle.text = "Recording Collections"
        self.navBarBackButton.setTitle("Back", for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DGStreamCore.instance.presentedViewController = self
        self.loadRecordingCollections()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "recordings",
            let vc = segue.destination as? DGStreamRecordingsViewController,
            let collection = sender as? DGStreamRecordingCollection {
            vc.collection = collection
        }
    }
    
    func loadRecordingCollections() {
        let collections = DGStreamRecordingCollection.createDGStreamRecordingCollectionsFrom(protocols: DGStreamManager.instance.dataSource.streamManager(DGStreamManager.instance, recordingCollectionsForUserID: DGStreamCore.instance.currentUser?.userID ?? 0))
        self.collections = collections
        self.tableView.reloadData()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension DGStreamRecordingCollectionsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.collections.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DGStreamRecordingCollectionsTableViewCell
        cell.configureWith(collection: self.collections[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "recordings", sender: self.collections[indexPath.row])
    }
}
