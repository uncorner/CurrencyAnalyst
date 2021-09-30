//
//  UITableViewExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis on 30.09.2021.
//  Copyright © 2021 uncorner. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    func scrollOnTop()  {
        if self.numberOfRows(inSection: 0) > 0 {
            self.scrollToRow(at: IndexPath(row: 0, section: 0), at: .none, animated: false)
        }
    }
    
}
