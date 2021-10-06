//
//  BindableType.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 06.10.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation

import UIKit
import RxSwift

protocol BindableType: AnyObject {
    associatedtype ViewModelType
    
    var viewModel: ViewModelType! { get set }
    
    func bindViewModel()
}

extension BindableType where Self: UIViewController {
    func bindViewModel(to model: Self.ViewModelType) {
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}

