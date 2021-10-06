import UIKit
import RxSwift

protocol MvvmSceneCoordinatorType {
    /// transition to another scene
    @discardableResult
    func transition(to scene: MvvmScene, type: MvvmSceneTransitionType) -> Completable
    
    /// pop scene from navigation stack or dismiss current modal
    @discardableResult
    func pop(animated: Bool) -> Completable
}

extension MvvmSceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
