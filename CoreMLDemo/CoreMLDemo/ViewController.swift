//
//  ViewController.swift
//  CoreMLDemo
//
//  Created by Chamin Morikawa: 2018-07-11.
//  Copyright ©2018 Yubi. All rights reserved.
//

import UIKit
import CoreML

class ViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var classifier: UILabel!
    @IBOutlet weak var segControlModel: UISegmentedControl!
    @IBOutlet weak var segControlQuantization: UISegmentedControl!
    
    var modelIndex: Int!
    var quantIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // default model is MobileNet
        modelIndex = 2
	segControlModel.selectedSegmentIndex = modelIndex
        // default quantization is 32 bit
        quantIndex = 0

	// done
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func camera(_ sender: Any) {
        
        if !UIImagePickerController.isSourceTypeAvailable(.camera) {
            return
        }
        
        let cameraPicker = UIImagePickerController()
        cameraPicker.delegate = self
        cameraPicker.sourceType = .camera
        cameraPicker.allowsEditing = false
        
        present(cameraPicker, animated: true)
    }
    
    @IBAction func openLibrary(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }
    
    @IBAction func changeModel(_ sender: Any) {
        modelIndex = segControlModel.selectedSegmentIndex
        quantIndex = segControlQuantization.selectedSegmentIndex
    }

}

extension ViewController: UIImagePickerControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @available(iOS 12.0, *)
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true)
        classifier.text = "Analyzing Image..."
        guard let image = info["UIImagePickerControllerOriginalImage"] as? UIImage else {
            return
        } 
        
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 224, height: 224), true, 2.0)
        image.draw(in: CGRect(x: 0, y: 0, width: 224, height: 224))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let attrs = [kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue, kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue] as CFDictionary
        var pixelBuffer : CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(newImage.size.width), Int(newImage.size.height), kCVPixelFormatType_32ARGB, attrs, &pixelBuffer)
        guard (status == kCVReturnSuccess) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer!)
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pixelData, width: Int(newImage.size.width), height: Int(newImage.size.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) 
        
        context?.translateBy(x: 0, y: newImage.size.height)
        context?.scaleBy(x: 1.0, y: -1.0)
        
        UIGraphicsPushContext(context!)
        newImage.draw(in: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
        UIGraphicsPopContext()
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        imageView.image = newImage
        imageView.contentMode = UIViewContentMode.scaleAspectFit
        
        // Core ML
        var b:String
        b = "0"
        
        // overall index for model selection
        let selectionIndex = 4*quantIndex + modelIndex
        
        switch selectionIndex {
        
        case 0:
            let model = VGG16()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end detection
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
        
        case 1:
            let model = Resnet50()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
        
        case 2:
            let model = MobileNet()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
        
        case 3:
            let model = MobileNetV2()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
            
        case 4:
            let model = VGG16QInt8()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
            
        case 5:
            //self.showMessageToUser(title: "ResNet50: quantized", msg: "This model is not supported")
            let model = ResNet50QInt8()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
            
        case 6:
            //self.showMessageToUser(title: "MobileNet: quantized", msg: "This model is not supported")
            let model = MobileNetQInt8()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
            
        case 7:
            //self.showMessageToUser(title: "MobileNet V2: quantized", msg: "This model is not supported")
            let model = MobileNetV2QInt8()
            let start = DispatchTime.now() // <<<<<<<<<< Start time
            guard let prediction = try? model.prediction(image: pixelBuffer!) else {
                return
            }
            let end = DispatchTime.now()   // <<<<<<<<<<   end time
            
            let nanoTime = end.uptimeNanoseconds - start.uptimeNanoseconds // <<<<< Difference in nano seconds (UInt64)
            let timeInterval = Double(nanoTime) / 1_000_000_000 // Technically could overflow for long running tests
            classifier.text = "AI thinks this is a \(prediction.classLabel)."
            b = String(format:"%f milliseconds", timeInterval*1000)
            
        default:
            self.showMessageToUser(title: "Unrecognized model", msg: "This model is not supported")
            b = String(format:"Could not perform inference.")
            
        }
        
        // show alert with forward pass time
        self.showMessageToUser(title: "Forward Pass time", msg: b)
    }
    
    func showMessageToUser(title: String, msg: String)  {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}


