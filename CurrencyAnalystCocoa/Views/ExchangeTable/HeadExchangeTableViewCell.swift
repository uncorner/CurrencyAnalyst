//
//  HeadExchangeTableViewCell.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 02.09.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class HeadExchangeTableViewCell: UITableViewCell {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var mapMarkerImageView: UIImageView!
    
    static let cellId = "HeadExchangeTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
                
        locationLabel.textColor = Styles.MainViewController.HeadExchangeTableViewCell.locationLabelColor
        infoLabel.textColor = Styles.MainViewController.HeadExchangeTableViewCell.infoLabelColor
        mapMarkerImageView.image = UIImage(systemName: "mappin.and.ellipse")
        mapMarkerImageView.tintColor = Styles.MainViewController.HeadExchangeTableViewCell.mapMarkerImageViewColor
        
        backgroundColor = .clear
        selectionStyle = .none
    }
    
}
