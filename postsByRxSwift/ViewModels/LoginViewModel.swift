//
//  LoginViewModel.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import Foundation
import RxSwift
import RxCocoa


class LoginViewModel {
    
    let onShowError = PublishSubject<SingleButtonAlert>()
    let onSuccess = PublishSubject<Void>()
    
    let loginButtonTapped = PublishSubject<Void>()
    
    var emailId = BehaviorRelay<String>(value: "")
    var password = BehaviorRelay<String>(value: "")
    
    private let isLoading = BehaviorRelay<Bool>(value: false)
    private let apiClient: ApiClient
    private let disposeBag = DisposeBag()
    
    var onShowLoadingHud: Observable<Bool> {
        return isLoading
            .asObservable()
            .distinctUntilChanged()
    }
    
    var loginButtonEnabled: Observable<Bool> {
      return Observable
        .combineLatest(emailId, password) { email, password in
          return email.validateEmail() && password.validatePassword()
        }
    }
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
        
        loginButtonTapped
            .subscribe(
                onNext: { [weak self] in
                    self?.loginUser()
                }
            )
            .disposed(by: disposeBag)
    }
    
    private func loginUser(){
        self.isLoading.accept(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.isLoading.accept(false)
            self.onSuccess.onNext(())
        }
    }

}
