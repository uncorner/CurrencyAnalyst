import UIKit

extension MvvmScene {
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch self {
        case .exchangeListViewModel(let viewModel):
            let nc = storyboard.instantiateViewController(withIdentifier: "ExchangeList") as! UINavigationController
            let vc = nc.viewControllers.first as! MainViewController
            vc.bindViewModel(to: viewModel)
            return nc
        case .pickCityViewModel(let viewModel):
            let vc = storyboard.instantiateViewController(withIdentifier: "PickCity") as! PickCityViewController
            vc.bindViewModel(to: viewModel)
            return vc
        }
    }
}
