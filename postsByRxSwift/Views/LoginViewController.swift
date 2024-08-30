//
//  ViewController.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import UIKit
import RxSwift
import PKHUD

class ViewController: UIViewController, SingleButtonDialogPresenter {
    
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var loginButton: UIButton!
    
    private let viewModel = LoginViewModel()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = Constants.Titles.login
        navigationController?.navigationBar.prefersLargeTitles = false

        emailTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.LoginConstants.TFWidth, height: Constants.LoginConstants.TFHeight))
        emailTextField.leftViewMode = .always
        
        passwordTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.LoginConstants.TFWidth, height: Constants.LoginConstants.TFHeight))
        passwordTextField.leftViewMode = .always
        
        setUpBinding();
        setUpObservables()
        
    }

    private func setUpBinding() {
        
        emailTextField.rx.text.orEmpty
            .bind(to: viewModel.emailId)
            .disposed(by: disposeBag)
        
        passwordTextField.rx.text.orEmpty
            .bind(to: viewModel.password)
            .disposed(by: disposeBag)
        
        viewModel.loginButtonEnabled
        .bind(to: loginButton.rx.isEnabled)
        .disposed(by: disposeBag)
        
        loginButton.rx.tap.asObservable()
            .bind(to: viewModel.loginButtonTapped)
            .disposed(by: disposeBag)

    }
    
    private func setUpObservables() {

        viewModel
            .onShowLoadingHud
            .map { [weak self] in self?.setLoadingHud(visible: $0) }
            .subscribe()
            .disposed(by: disposeBag)

        viewModel
            .onSuccess
            .subscribe(
                onNext: { [weak self] in
                    self?.pushToTabbarVC()
                }
            ).disposed(by: disposeBag)

        viewModel
            .onShowError
            .map { [weak self] in self?.presentSingleButtonDialog(alert: $0)}
            .subscribe()
            .disposed(by: disposeBag)

    }
    
    private func pushToTabbarVC() {
        let storyboard = UIStoryboard(name: Constants.StoryBoardName.main, bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: Constants.VCIdentifier.tabbarViewController)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    private func setLoadingHud(visible: Bool) {
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        visible ? PKHUD.sharedHUD.show(onView: view) : PKHUD.sharedHUD.hide()
    }
}


