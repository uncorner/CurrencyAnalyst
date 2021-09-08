//
//  ExchangeTableViewCell.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 06.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class ExchangeTableViewCell: UITableViewCell {
    static let cellId = "ExchangeTableViewCell"

    @IBOutlet weak var exchangeBoxView: ExchangeBoxView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var bankTitleLabel: UILabel!
    @IBOutlet weak var logoImageView: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        headerView.layer.cornerRadius = 10
        headerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        headerView.backgroundColor = Styles.MainViewController.ExchangeTableViewCell.headerBackColor
        
        mainView.layer.cornerRadius = 10
        mainView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        mainView.backgroundColor = Styles.MainViewController.ExchangeTableViewCell.mainViewBackColor
        
        exchangeBoxView.usdBuyAtLabel.textColor = Styles.MainViewController.ExchangeTableViewCell.buyAtOrSellAtLabelColor
        exchangeBoxView.usdSellAtLabel.textColor = Styles.MainViewController.ExchangeTableViewCell.buyAtOrSellAtLabelColor
        
        exchangeBoxView.euroBuyAtLabel.textColor = Styles.MainViewController.ExchangeTableViewCell.buyAtOrSellAtLabelColor
        exchangeBoxView.euroSellAtLabel.textColor = Styles.MainViewController.ExchangeTableViewCell.buyAtOrSellAtLabelColor
        
        bankTitleLabel.textColor = Styles.MainViewController.ExchangeTableViewCell.bankTitleLabelColor
        bankTitleLabel.font = Styles.MainViewController.ExchangeTableViewCell.bankTitleLabelFont
        
        backgroundColor = .clear
    }

}
