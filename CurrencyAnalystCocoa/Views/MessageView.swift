//
//  MessageView2.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 21.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class MessageView: UIView {
    
    let messageLabel = UILabel()
    let imageView = UIImageView()
    
    
    init(text: String, systemImageName: String) {
        super.init(frame: UIScreen.main.bounds)
        
        setupConstraints(systemImageName, text)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    private func setupConstraints(_ systemImageName: String, _ text: String) {
        heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        addSubview(imageView)
        imageView.layoutToSuperview(.leading, offset: 20)
        imageView.layoutToSuperview(.centerY)
        imageView.image = UIImage(systemName: systemImageName)
        
        addSubview(messageLabel)
        messageLabel.numberOfLines = 0
        messageLabel.text = text
        
        messageLabel.layout(.leading, to: .trailing, of: imageView, offset: 10)
        messageLabel.layoutToSuperview(.centerY)
        messageLabel.layoutToSuperview(.trailing, offset: -20)
    }
    
}
