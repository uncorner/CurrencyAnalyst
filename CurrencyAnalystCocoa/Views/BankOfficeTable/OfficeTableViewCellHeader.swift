//
//  OfficeTableViewCellHeader.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 01.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class OfficeTableViewCellHeader: UITableViewCell {

    static let cellId = "OfficeTableViewCellHeader"
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var boxView: UIView!
    @IBOutlet weak var expandImageView: UIImageView!
    @IBOutlet weak var bridgeView1: UIView!
    @IBOutlet weak var bridgeView2: UIView!
    
    static let upArrowImage: UIImage! = UIImage(systemName: "chevron.up")
    static let downArrowImage: UIImage! = UIImage(systemName: "chevron.down")
    
    static func nib() -> UINib {
        return UINib(nibName: cellId, bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        backgroundColor = .clear
        boxView.layer.cornerRadius = 10
        boxView.backgroundColor = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCellHeader.boxViewBackColor
        expandImageView.tintColor = .gray
        
        headerLabel.font = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCellHeader.headerLabelFont
        headerLabel.textColor = Styles.DetailBankViewController.OfficeTableBoxView.OfficeTableViewCellHeader.headerLabelColor
        
        show(isExpanded: false)
    }
    
    func show(isExpanded: Bool) {
        if isExpanded {
            expandImageView.image = Self.upArrowImage
            boxView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            
            bridgeView1.backgroundColor = boxView.backgroundColor
            bridgeView2.backgroundColor = boxView.backgroundColor
        }
        else {
            expandImageView.image = Self.downArrowImage
            boxView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            bridgeView1.backgroundColor = .clear
            bridgeView2.backgroundColor = .clear
        }
    }
 
}
