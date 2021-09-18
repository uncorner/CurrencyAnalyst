//
//  BaseViewController.swift
//  CurrencyAnalystCocoa
//
//  Created by Denis Uncorner on 05.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import RxSwift

class BaseViewController: UIViewController, UIGestureRecognizerDelegate {
    static let imageCache: NSCache<NSString, UIImage> = NSCache()
    private var backgroundImageView: UIImageView!
    let disposeBag = DisposeBag()
    
    lazy var dataSource = ExchangeDataSourceFactory.create()
    lazy var networkService = NetworkServiceFactory.create(dataSource: dataSource)
    lazy var imageLoader = CachedImageLoader(cache: Self.imageCache, networkService: networkService)
    
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
    
    override func viewDidLayoutSubviews() {
        backgroundImageView.frame = view.frame
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.center = view.center
    }
    
    private func setupBackgroundImage() {
        backgroundImageView = UIImageView(image: UIImage(named: "wallpaper_image"))
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
        navigationController?.popViewController(animated: true)
    }
    
}
