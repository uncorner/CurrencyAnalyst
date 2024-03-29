import UIKit

extension MvvmScene {
    
    func viewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        switch self {
        case .exchangeList(let viewModel):
            let result = fetchViewController(id: "ExchangeList", viewModel, storyboard) as (ExchangeListViewController,UIViewController)
            return result.1
        case .pickCity(let viewModel):
            let result = fetchViewController(id: "PickCity", viewModel, storyboard) as (PickCityViewController,UIViewController)
            return result.1
        case .detailBank(let viewModel):
            let result = fetchViewController(id: "DetailBank", viewModel, storyboard) as (DetailBankViewController,UIViewController)
            return result.1
        case .officeMap(let viewModel):
            let result = fetchViewController(id: "OfficeMap", viewModel, storyboard) as (MapViewController,UIViewController)
            return result.1
        }
    }
    
    private func fetchViewController<T>(id: String, _ viewModel: T.ViewModelType, _ storyboard: UIStoryboard) -> (T, UIViewController)
    where T:(MvvmBindableType & UIViewController)
    {
        let vc = storyboard.instantiateViewController(withIdentifier: id)
        var bindableVc: T
        
        if let navigationVc = vc as? UINavigationController {
            bindableVc = navigationVc.viewControllers.first as! T
            bindableVc.bindViewModel(to: viewModel)
            return (bindableVc,navigationVc)
        }
        
        bindableVc = vc as! T
        bindableVc.bindViewModel(to: viewModel)
        return (bindableVc,bindableVc)
    }
    
}
