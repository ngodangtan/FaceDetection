//
//  ViewController.swift
//  faceDetach
//
//  Created by Ngo Dang tan on 9/25/20.
//  Copyright © 2020 Ngo Dang tan. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let faceMask: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToFaceMask(_:)), for: .touchUpInside)
        button.setTitle("Face Mask FRT", for: .normal)
        let icon = UIImage(systemName: "eye")?.resized(newSize: CGSize(width: 50, height: 30))
        button.addRightImage(image: icon!, offset: 30)
        button.backgroundColor = .systemGreen
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = UIColor.systemGreen.cgColor
        
        return button
    }()
    
    let faceDetach: BtnPleinLarge = {
        let button = BtnPleinLarge()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(buttonToFaceDetach(_:)), for: .touchUpInside)
        button.setTitle("Face Detection FRT", for: .normal)
        let icon = UIImage(systemName: "eye")?.resized(newSize: CGSize(width: 50, height: 30))
        button.addRightImage(image: icon!, offset: 30)
        button.backgroundColor = .systemGreen
        button.layer.borderColor = UIColor.systemGreen.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowColor = UIColor.systemGreen.cgColor
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    private func setupView(){
        view.addSubview(faceMask)
        
        faceMask.centerX(inView: view)
        faceMask.anchor(top: view.safeAreaLayoutGuide.topAnchor,paddingTop: 30)
        faceMask.setDimensions(height: 70, width: view.frame.width - 40)
        
        view.addSubview(faceDetach)
        faceDetach.centerX(inView: view)
        faceDetach.anchor(top: faceMask.bottomAnchor,paddingTop: 30)
        faceDetach.setDimensions(height: 70, width: view.frame.width - 40)
        
    }
    @objc func buttonToFaceMask(_ sender: BtnPleinLarge) {
        
//        let controller = FaceMaskViewController()
//        self.navigationController?.pushViewController(controller, animated: true)
        
        let controller = HomeController()
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func buttonToFaceDetach(_ sender: BtnPleinLarge)  {
        let controller = FaceDetachViewController()
        self.navigationController?.pushViewController(controller, animated: true)

    }
    
    
}

