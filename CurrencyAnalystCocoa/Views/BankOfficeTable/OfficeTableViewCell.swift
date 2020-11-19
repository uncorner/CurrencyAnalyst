//
//  OfficeTableViewCell.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 30.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class OfficeTableViewCell: UITableViewCell {
    static let cellId = "OfficeTableViewCell"

    @IBOutlet weak var contentStackView: UIStackView!
    @IBOutlet weak var boxView: UIView!
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        boxView.layer.cornerRadius = Styles.cornerRadius1
        boxView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        boxView.backgroundColor = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCell.boxViewBackColor
    }

    
}
