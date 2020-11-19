//
//  WindowExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 21.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

extension UIWindow {
    static var isLandscape: Bool {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation
                .isLandscape ?? false
        } else {
            return UIApplication.shared.statusBarOrientation.isLandscape
        }
    }
}
