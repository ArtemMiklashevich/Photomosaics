//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Artem Miklashevich on 10/17/17.
//  Copyright © 2017 Artem Miklashevych. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var originalImage: UIImageView!
    @IBOutlet weak var filteredImage: UIImageView!
    @IBOutlet weak var filtersScrollView: UIScrollView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var CIFilterNames = [
        "CIPhotoEffectChrome",
        "CIPhotoEffectFade",
        "CIPhotoEffectInstant",
        "CIPhotoEffectNoir",
        "CIPhotoEffectProcess",
        "CIPhotoEffectTonal",
        "CIPhotoEffectTransfer",
        "CISepiaTone"
    ]
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNewImage(newImage: originalImage.image!)
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        
        let actionSheet = UIAlertController(title: "Photo Source", message: "Choose a source", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)}))
        
        actionSheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {(action: UIAlertAction) in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController,animated: true, completion: nil)}))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        setNewImage(newImage: image)
        picker .dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func setNewImage(newImage: UIImage) {
        var X: CGFloat = 4
        let Y: CGFloat = 4
        let buttonWidth:CGFloat = 70
        let buttonHeight: CGFloat = 70
        
        let subViews = filtersScrollView.subviews
        for s in subViews {
            s.removeFromSuperview()
        }
        
        originalImage.image = newImage
        filteredImage.image = newImage
        let targetSize = CGSize(width: 140, height: 140)
        
        let smallImage = resizeImage(image: newImage, targetSize: targetSize)
        var itemCount = 0
        
        for i in 0..<CIFilterNames.count {
            itemCount = i
            
            let filterButton = UIButton(type: .custom)
            filterButton.frame = CGRect(x: X, y: Y, width: buttonWidth, height: buttonHeight)
            filterButton.tag = i
            filterButton.addTarget(self, action:#selector(filterButtonTapped(_:)), for: .touchUpInside)
            filterButton.layer.cornerRadius = 6
            filterButton.clipsToBounds = true
            
            let imageForButton = applyFilter(image: smallImage, filterIndex: i)
            filterButton.setBackgroundImage(imageForButton, for: .normal)
            
            X +=  buttonWidth + 4
            filtersScrollView.addSubview(filterButton)
        }
        filtersScrollView.contentSize = CGSize(width: (buttonWidth + 4) * CGFloat(itemCount + 1) + 4, height: Y)
    }
    
    func applyFilterForBigImage(img: UIImage, fltIndex: Int){
        spinner.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.filteredImage.image = self.applyFilter(image: img, filterIndex: fltIndex)
            self.spinner.stopAnimating()
        }
    }
    
    func applyFilter(image: UIImage, filterIndex: Int) -> UIImage {
        let ciContext = CIContext(options: nil)
        let coreImage = CIImage(image: image)
        let filter = CIFilter(name: "\(CIFilterNames[filterIndex])" )
        filter!.setDefaults()
        filter!.setValue(coreImage, forKey: kCIInputImageKey)
        let filteredImageData = filter!.value(forKey: kCIOutputImageKey) as! CIImage
        let filteredImageRef = ciContext.createCGImage(filteredImageData, from: filteredImageData.extent)
        let result = UIImage(cgImage: filteredImageRef!)
        return result
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
    
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    @objc func filterButtonTapped(_ sender: UIButton) {
        let indexFilter = sender.tag
        applyFilterForBigImage(img: originalImage.image!, fltIndex: indexFilter)
    }
    
    @IBAction func savePicButton(_ sender: Any) {
        UIImageWriteToSavedPhotosAlbum(filteredImage.image!, self, nil, nil)
        let alert = UIAlertController(title: "Photo Filters", message: "Your image has been saved to Photo Library", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Save", style: .default))
        self.present(alert, animated: true)
    }
}
