//
//  InfoExchangeTableViewCell.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 25.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class InfoExchangeTableViewCell: UITableViewCell {

    static let cellId = "InfoExchangeTableViewCell"

    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var boxView: UIView!
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        boxView.layer.cornerRadius = Styles.cornerRadius1
        boxView.backgroundColor = Styles.MainViewController.InfoExchangeTableViewCell.boxViewBackColor
        infoLabel.textColor = Styles.MainViewController.InfoExchangeTableViewCell.infoLabelTextColor
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
}
