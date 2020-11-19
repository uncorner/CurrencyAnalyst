//
//  ColorExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 22.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

extension UIColor {
    // #rrggbbaa
    public convenience init(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            var hexColor = String(hex[start...])
            
            if hexColor.count == 6 {
                hexColor.append("ff")
            }
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        self.init(red: 0, green: 0, blue: 0, alpha: 1)
    }
}
