//
//  SceneDelegate.swift
//  CurrencyAnalystCocoa
//
//  Created by denis2 on 04.07.2020.
//  Copyright © 2020 uncorner. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        setupMvvmSceneCoordinator(window: window!)
    }
    
    private func setupMvvmSceneCoordinator(window: UIWindow) {
        let sceneCoordinator = MvvmSceneCoordinator(window: window)
        
        let networkService = getNetworkService()
        let viewModel = ExchangeListViewModel(sceneCoordinator: sceneCoordinator, networkService: networkService, storageRepository: getStorageRepository() )
        let firstScene = MvvmScene.exchangeList(viewModel)
        sceneCoordinator.transition(to: firstScene, type: .root)
    }
    
    private func getNetworkService() -> NetworkService {
        let dataSource = ExchangeDataSourceFactory.create()
        return NetworkServiceFactory.create(dataSource: dataSource)
    }
    
    private func getStorageRepository() -> StorageRepository {
        CoreDataStorageRepository()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        let nc = NotificationCenter.default
        nc.post(name: Constants.Notifications.didEnterBackground, object: nil)
    }


}

