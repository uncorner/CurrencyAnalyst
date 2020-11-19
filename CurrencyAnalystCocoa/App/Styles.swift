//
//  Styles.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 06.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

struct Styles {
    static let white1Color = UIColor(hex: "#f5f5f5ff")
    static let gray1Color = UIColor(hex: "#d9d9d9ff")
    static let gray2Color = UIColor(hex: "#4E4E4E")
    static let gray3Color = UIColor(hex: "#363636")
    static let blue1Color = UIColor(hex: "#9cc8e6ff")
    static let blue2Color = UIColor(hex: "#06152e")
    static let blue3Color = UIColor(hex: "#182C54")
    static let yellow1Color = UIColor(hex: "#e0d292")
    static let yellow2Color = UIColor(hex: "#ebeb9b")
    static let brown1Color = UIColor(hex: "#422700")
    static let black1Color = UIColor(hex: "#242424")
    static let cornerRadius1: CGFloat = 10
    
    
    struct SearchBarStyle {
        var backColor: UIColor?
        var textColor: UIColor?
        var leftViewColor: UIColor?
    }
    
    struct CommonActivityAnimating {
        static let activityColor = UIColor.white
        static let backgroundColor = UIColor.clear
    }
    
    struct ExchangeBoxView {
        static let bestRateColor = UIColor(hex: "#bf2608")
        static let defaultRateColor = black1Color
        static let buyAtAndSellAtLabelColor = gray2Color
    }
    
    struct MainViewController {
        
        struct NavigationBar {
            static let titleColor = UIColor.white
        }
        
        struct Cb {
            static let currencySignColor = UIColor(hex: "#a9db9eff")
            static let currencyRateLabelColor = yellow2Color
            static let cbRubleSignLabelColor = gray1Color
            static let cbLabelColor = gray1Color
        }
        
        struct HeadExchangeTableViewCell {
            static let locationLabelColor = blue1Color
            static let infoLabelColor = Styles.gray1Color
            static let mapMarkerImageViewColor = Styles.blue1Color
        }
        
        struct ExchangeTableViewCell {
            static let headerBackColor = UIColor(hex: "#8fbaade6")
            static let mainViewBackColor = UIColor(hex: "#8fbaadc8")
            static let buyAtOrSellAtLabelColor = gray2Color
            static let bankTitleLabelColor = blue3Color
            static let bankTitleLabelFont = UIFont(name: "Helvetica", size: 17)
        }
        
        struct InfoExchangeTableViewCell {
            static let boxViewBackColor = ExchangeTableViewCell.mainViewBackColor
            static let infoLabelTextColor = UIColor(hex: "#363636")
        }
        
        struct TableView {
            static let exchangeTableViewCellSelectionColor = UIColor(hex: "#C8C8C832")
        }
        
    }
    
    struct DetailBankViewController {
        
        static let boxTitleFont = UIFont(name: "Helvetica", size: 17)
        static let titleLabelColor = white1Color
        
        struct DetailBoxView {
            static let cornerRadius: CGFloat = cornerRadius1
            static let backgroundColor = UIColor(hex: "#a3a3a364")
            static let defaultRateColor = yellow2Color
            static let bestRateColor = ExchangeBoxView.bestRateColor
            static let bestRateBackColor = UIColor(hex: "#c9c9c996")
            static let buyAtAndSellAtLabelColor = UIColor(hex: "#c4c46e")
            
            static let rubleSignColor = gray1Color
            
            static let updatedTimeLabelColor = gray1Color
        }
        
        struct OfficeTableBoxView {
            static let backgroundColor = UIColor(hex: "#a3a3a364")
            static let mapButtonBackColor = UIColor(hex: "#57575796")
            static let mapButtonColor = Styles.white1Color
            
            struct OfficeTableViewCell {
                static let boxViewBackColor = UIColor(hex: "#f0dea8c8")
                static let contentLabelFont = UIFont(name: "Helvetica", size: 16)
                static let contentLabelColor = gray3Color
            }
            
            struct OfficeTableViewCellHeader {
                static let boxViewBackColor = OfficeTableViewCell.boxViewBackColor
                static let headerLabelFont = UIFont(name: "Helvetica", size: 17)
                static let headerLabelColor = brown1Color
            }
        }
        
    }
    
    struct PickCityViewController {
        static let boxViewBackColor = Styles.DetailBankViewController.DetailBoxView.backgroundColor
        
        static let searchBarStyle = SearchBarStyle(backColor: UIColor(hex: "#a3a3a396"), textColor: white1Color, leftViewColor: white1Color)
        
        struct PickCityTableViewCell {
            static let titleLabelTextColor = UIColor.white
            static let checkboxImageTintColor = UIColor(hex: "#d1d1d1")
        }
        
        static let tableSeparatorColor = UIColor(hex: "#a1a1a1")
        
    }
    
    struct MapViewController {
        static let markerColor = UIColor(hex: "#ffb300")
    }
    
}
