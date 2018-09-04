//
//  DGStreamMergeIntensityViewController.swift
//  DGStream
//
//  Created by Brandon on 8/23/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit

protocol DGStreamCallMergeIntensityDelegate {
    func selected(intensity: Float)
}

class DGStreamMergeIntensityViewController: UIViewController {

    @IBOutlet weak var intensitySlider: UISlider!
    
    var mergeColor: UIColor = .clear
    var intensity:Float = 0.0
    
    var delegate: DGStreamCallMergeIntensityDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.intensitySlider.minimumValue = 0.2
        self.intensitySlider.maximumValue = 0.8
        self.intensitySlider.value = intensity
        self.intensitySlider.setValue(intensity, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.intensitySlider.minimumValue = 0.2
        self.intensitySlider.maximumValue = 0.8
        self.intensitySlider.value = intensity
        self.intensitySlider.setValue(intensity, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sizeSliderValueChanged(_ sender: Any) {
        let value = self.intensitySlider.value
        if let delegate = self.delegate {
            self.intensity = value
            delegate.selected(intensity: value)
        }
    }
    
    @IBAction func touchUpInside(_ sender: Any) {
        self.storeValues()
    }
    
    @IBAction func touchUpOutside(_ sender: Any) {
        self.storeValues()
    }
    
    func storeValues() {
        
        var color = ""
        if self.mergeColor == .green {
            color = "green"
        }
        else if self.mergeColor == .blue {
            color = "blue"
        }
        else if self.mergeColor == .red {
            color = "red"
        }
        else if self.mergeColor == .white {
            color = "white"
        }
        else {
            color = "black"
        }
        
        UserDefaults.standard.set(color, forKey: "MergeColor")
        UserDefaults.standard.set(self.intensity, forKey: "MergeIntensity")
        UserDefaults.standard.synchronize()
    }

//    func stringForSliderValue() -> String {
//        let stringValue = String(self.intensitySlider.value)
//        print("String \(stringValue)")
//        let splice = stringValue.components(separatedBy: ".")[1]
//        let spliceString = NSString(string: splice)
//        var string = ""
//        if spliceString.length > 1 {
//            string = NSString(string: spliceString).substring(to: 2)
//        }
//        else {
//            string = NSString(string: spliceString).substring(to: 1)
//            string.append("0")
//        }
//        return "\(string)%"
//    }

}
