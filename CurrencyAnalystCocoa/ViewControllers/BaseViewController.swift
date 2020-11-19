//
//  BaseViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 05.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    private var backgroundImageView: UIImageView!
        
    func viewDidLoad(isRoot: Bool) {
        super.viewDidLoad()

        setupBackgroundImage()
        
        if !isRoot {
            setupBackButton()
        }
    }
    
    override func viewDidLoad() {
        self.viewDidLoad(isRoot: false)
    }
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        setBackgroundImage()
//    }
    
    override func viewDidLayoutSubviews() {
        backgroundImageView.frame = view.frame
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.center = view.center
    }
    
    private func setupBackgroundImage() {
        //set the frame of your imageView here to automatically adopt screen size changes (e.g. by rotation or splitscreen)
        //self.imageView.frame = self.view.bounds
        
        //        let imageView = UIImageView(frame: self.view.bounds)
        //        imageView.image = UIImage(named: "background-img")//if its in images.xcassets
        //        self.view.addSubview(imageView)
        
        //let backgroundImageView = UIImageView(image: UIImage(named: "background-img"))
        //let backgroundImageView = UIImageView(image: UIImage(named: "limassol-night_blur"))
        
        //backgroundImageView = UIImageView(image: UIImage(named: "background_image"))
        // limassol_222
        backgroundImageView = UIImageView(image: UIImage(named: "wallpaper_image"))
        
        //backgroundImageView = UIImageView(image: UIImage(named: "background_image_m"))
        
        //backgroundImageView.frame = view.frame
        //backgroundImageView.contentMode = .scaleAspectFill
        view.addSubview(backgroundImageView)
        view.sendSubviewToBack(backgroundImageView)
    }
    
   
    private func setupBackButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left.circle"),
            style: .plain,
            target: self,
            action: #selector(popToPrevious)
        )
        navigationController?.interactivePopGestureRecognizer?.delegate = self
    }
    
    @objc private func popToPrevious() {
        // our custom stuff
        navigationController?.popViewController(animated: true)
    }
    
}
