//
//  ControllerExtension.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 24.08.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit
import SwiftEntryKit
import Alamofire

extension UIViewController {
    
    func startActivityAnimatingAndLock(isActivityAnimating: Bool = true) {
        navigationController?.navigationBar.isUserInteractionEnabled = false
        if isActivityAnimating {
            activityStartAnimating()
        }
    }
    
    func stopActivityAnimatingAndUnlock() {
        navigationController?.navigationBar.isUserInteractionEnabled = true
        activityStopAnimating()
    }
    
    func activityStopAnimating() {
        view.activityStopAnimating()
    }
    
    func activityStartAnimating() {
        view.activityStartAnimating(activityColor: Styles.CommonActivityAnimating.activityColor, backgroundColor: Styles.CommonActivityAnimating.backgroundColor)
    }
    
    //private
    func processError(_ error: AFError) {
        print(error)
        var errorMessage: String = Constants.commonErrorMessage
        
        switch error.underlyingError {
        case let urlError as URLError:
            let netCodes: Set<URLError.Code> = [.timedOut, .notConnectedToInternet, .cannotConnectToHost, .networkConnectionLost]
            
            if netCodes.contains(urlError.code) {
                errorMessage = "Ошибка сети. Убедитесь, что устройство имеет доступ в интернет."
            }
            
        default:
            errorMessage = Constants.commonErrorMessage
        }
        
        // TODO
        DispatchQueue.main.async {
            self.showErrorMessage(text: errorMessage)
        }
    }
    
    //private
    func processError(_ error: Error) {
        print(error)
        // TODO
        DispatchQueue.main.async {
            self.showErrorMessage(text: Constants.commonErrorMessage)
        }
    }
    
    func processResponseError(_ error: Error) {
        if let afError = error as? AFError {
            processError(afError)
        }
        else {
            processError(error)
        }
    }
    
    func showErrorMessage(text: String) {
        let customView = MessageView(text: text, systemImageName: "exclamationmark.circle")
        customView.messageLabel.textColor = .white
        var attributes = EKAttributes()
        
        attributes = .float
        attributes.displayMode = .dark
        attributes.name = "error message"
        attributes.hapticFeedbackType = .success
        attributes.entryBackground = .color(color: .white)
        attributes.entryBackground = .gradient(
            gradient: .init(
                colors: [EKColor(UIColor(hex: "#996d7b")),
                         EKColor(UIColor(hex: "#ab2b55"))],
                startPoint: .zero,
                endPoint: CGPoint(x: 0, y: 1)
            )
        )
        attributes.popBehavior = .animated(
            animation: .init(
                translate: .init(duration: 0.3),
                scale: .init(from: 1, to: 0.7, duration: 0.7)
            )
        )
        attributes.shadow = .active(
            with: .init(
                color: .black,
                opacity: 0.5,
                radius: 10
            )
        )
        attributes.statusBar = .dark
        attributes.scroll = .enabled(
            swipeable: true,
            pullbackAnimation: .easeOut
        )
        attributes.positionConstraints.maxSize = .init(
            width: .constant(value: UIScreen.main.bounds.minEdge),
            height: .intrinsic
        )
        
        attributes.displayDuration = 3
        
        SwiftEntryKit.display(entry: customView, using: attributes)
    }
    
}
 
