//
//  ViewImageDemoViewController.swift
//  faceDetach
//
//  Created by Ngo Dang tan on 9/25/20.
//  Copyright © 2020 Ngo Dang tan. All rights reserved.
//

import UIKit
class ViewImageDemoViewController: UIViewController {
    
    
    var image:UIImage?
    var viewImage: UIImageView!
    override func viewDidLoad() {
        viewImage = UIImageView(frame: CGRect(x: 0, y: 100, width: view.frame.size.width - 10, height: 800))
        viewImage.image = image
        view.addSubview(viewImage)
    }
    
    
    
}
