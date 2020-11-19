//
//  PickCityTableViewCell.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 10.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class PickCityTableViewCell: UITableViewCell {
    static let cellId = "PickCityTableViewCell"
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var checkboxImage: UIImageView!
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        backgroundColor = .clear
        titleLabel.textColor = Styles.PickCityViewController.PickCityTableViewCell.titleLabelTextColor
        selectionStyle = .none
        
        checkboxImage.tintColor = Styles.PickCityViewController.PickCityTableViewCell.checkboxImageTintColor
        
    }
    
    
}
