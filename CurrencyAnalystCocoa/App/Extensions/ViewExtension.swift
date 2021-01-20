//
//  ViewExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 16.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

extension UIView{
    
    private var backTagNumber: Int {
        475647
    }
    
    func activityStartAnimating(activityColor: UIColor, backgroundColor: UIColor) {
        let backgroundView = UIView()
        backgroundView.frame = CGRect.init(x: 0, y: 0, width: self.bounds.width, height: self.bounds.height)
        backgroundView.backgroundColor = backgroundColor
        backgroundView.tag = backTagNumber
        
        var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator = UIActivityIndicatorView(frame: CGRect.init(x: 0, y: 0, width: 50, height: 50))
        activityIndicator.center = self.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = activityColor
        activityIndicator.startAnimating()
        self.isUserInteractionEnabled = false
        
        backgroundView.addSubview(activityIndicator)
        
        self.addSubview(backgroundView)
    }
    
    func activityStopAnimating() {
        if let background = viewWithTag(backTagNumber){
            background.removeFromSuperview()
        }
        self.isUserInteractionEnabled = true
    }
    
}

extension CGRect {
    var minEdge: CGFloat {
        return min(width, height)
    }
}

extension UILabel {
    func setNewFont(fontName: String) {
        let oldFont = self.font
        guard let strongOldFont = oldFont else {return}
        self.font = UIFont(name: fontName, size: strongOldFont.pointSize)
    }
}

extension UISearchBar {
    
    func setupStyle(backColor: UIColor? = nil, textColor: UIColor? = nil, leftViewColor: UIColor? = nil) {
        if let textfield = self.value(forKey: "searchField") as? UITextField {
            textfield.backgroundColor = backColor
            textfield.textColor = textColor
            
            if let leftView = textfield.leftView as? UIImageView {
                leftView.image = leftView.image?.withRenderingMode(.alwaysTemplate)
                leftView.tintColor = leftViewColor
            }
        }
    }
    
    func setupStyle(style: Styles.SearchBarStyle) {
        setupStyle(backColor: style.backColor, textColor: style.textColor, leftViewColor: style.leftViewColor)
    }
    
}

extension UIBarButtonItem {
    static func menuButton(_ target: Any?, action: Selector, imageName: String) -> UIBarButtonItem {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: imageName), for: .normal)
        button.addTarget(target, action: action, for: .touchUpInside)

        let menuBarItem = UIBarButtonItem(customView: button)
        menuBarItem.customView?.translatesAutoresizingMaskIntoConstraints = false
        menuBarItem.customView?.heightAnchor.constraint(equalToConstant: 24).isActive = true
        menuBarItem.customView?.widthAnchor.constraint(equalToConstant: 24).isActive = true

        return menuBarItem
    }
}


