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
        print(#function)
        navigationController?.navigationBar.isUserInteractionEnabled = false
        if isActivityAnimating {
            activityStartAnimating()
        }
    }
    
    func stopActivityAnimatingAndUnlock() {
        print(#function)
        navigationController?.navigationBar.isUserInteractionEnabled = true
        activityStopAnimating()
    }
    
    func activityStopAnimating() {
        view.activityStopAnimating()
    }
    
    func activityStartAnimating() {
        view.activityStartAnimating(activityColor: Styles.CommonActivityAnimating.activityColor, backgroundColor: Styles.CommonActivityAnimating.backgroundColor)
    }
    
    private func processError(_ error: AFError) {
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
        
        showErrorMessage(text: errorMessage)
    }
    
    private func processError(_ error: Error) {
        showErrorMessage(text: Constants.commonErrorMessage)
    }
    
    func processResponseError(_ error: Error) {
        print(error)
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
        attributes.displayMode = .light
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
        //attributes.statusBar = .dark
        attributes.statusBar = .light
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
 
