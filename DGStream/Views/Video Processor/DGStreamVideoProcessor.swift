//
//  DGStreamVideoProcessor.swift
//  DGStream
//
//  Created by Brandon on 6/22/18.
//  Copyright © 2018 Dataglance. All rights reserved.
//

import UIKit
import GPUImage2

class DGStreamVideoProcessor: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    func configureWithin(container: UIView) {
        self.boundInside(container: container)
        let renderView = RenderView(frame: self.bounds)
        renderView.boundInside(container: self)
    }
    
    func process(forgroundImage: UIImage, backgroundImage: UIImage) -> UIImage {
        
        let background = CIImage(image: backgroundImage)
        let forground = CIImage(image: forgroundImage)
        
        let chromaCIFilter = self.chromaKeyFilter(fromHue: 0.2, toHue: 0.5)
        chromaCIFilter?.setValue(forground, forKey: kCIInputImageKey)
        let sourceCIImageWithoutBackground = chromaCIFilter?.outputImage
        
        let compositor = CIFilter(name:"CISourceOverCompositing")
        compositor?.setValue(sourceCIImageWithoutBackground, forKey: kCIInputImageKey)
        compositor?.setValue(background, forKey: kCIInputBackgroundImageKey)
        var ciImage: CIImage = CIImage()
        if let compositedCIImage = compositor?.outputImage {
            ciImage = compositedCIImage
        }
        let image = UIImage(ciImage: ciImage)
        return image
    }
    
    func chromaKeyFilter(fromHue: CGFloat, toHue: CGFloat) -> CIFilter?
    {
        // 1
        let size = 64
        var cubeRGB = [Float]()
        
        // 2
        for z in 0 ..< size {
            let blue = CGFloat(z) / CGFloat(size-1)
            for y in 0 ..< size {
                let green = CGFloat(y) / CGFloat(size-1)
                for x in 0 ..< size {
                    let red = CGFloat(x) / CGFloat(size-1)
                    
                    // 3
                    let hue = getHue(red: red, green: green, blue: blue)
                    let alpha: CGFloat = (hue >= fromHue && hue <= toHue) ? 0: 1
                    
                    // 4
                    cubeRGB.append(Float(red * alpha))
                    cubeRGB.append(Float(green * alpha))
                    cubeRGB.append(Float(blue * alpha))
                    cubeRGB.append(Float(alpha))
                }
            }
        }
        
        let data = Data(buffer: UnsafeBufferPointer(start: &cubeRGB, count: cubeRGB.count))
        
        // 5
        let colorCubeFilter = CIFilter(name: "CIColorCube", withInputParameters: ["inputCubeDimension": size, "inputCubeData": data])
        return colorCubeFilter
    }
    
    func getHue(red: CGFloat, green: CGFloat, blue: CGFloat) -> CGFloat
    {
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1)
        var hue: CGFloat = 0
        color.getHue(&hue, saturation: nil, brightness: nil, alpha: nil)
        return hue
    }

}
