//
//  PostViewModel.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostViewModel {
    
    let posts = PublishRelay<[RPost]>()
    let onShowError = PublishRelay<SingleButtonAlert>()
    
    private let isLoading = BehaviorRelay(value: true)
    private let isEmptyArray = BehaviorRelay(value: true)
    
    private var apiClient: ApiClient
    private let bag = DisposeBag()
    
    private var postArray = [RPost]()
    
    var onShowLoadingHud: Observable<Bool> {
        return isLoading
            .asObservable()
            .distinctUntilChanged()
    }
    
    var onShowEmptyView: Observable<Bool> {
        return isEmptyArray
            .asObservable()
            .distinctUntilChanged()
    }
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func fetchPosts() {
        fetchRealmDBData() ? nil : fetchNetworkPosts()
    }
    
    func fetchNetworkPosts() {
        self.isLoading.accept(true)
        if Reachability.isConnectedToNetwork() {
            debugPrint("Log: calling post api to get latest data")
            self.apiClient
                .fetchPosts()
                .subscribe(
                    onNext: { [weak self] posts in
                        guard let self = self else { return }
                        guard posts.count > 0 else {
                            return
                        }
                        checkAndUpdate(posts: posts)
                        self.postArray.count == 0 ? isEmptyArray.accept(true): isEmptyArray.accept(false)
                        self.isLoading.accept(false)
                    },
                    onError: { [weak self] error in
                        guard let self = self else { return }
                        self.isLoading.accept(false)
                        let okAlert = SingleButtonAlert(
                            title: Constants.Titles.Alert,
                            message: (error as? ApiError)?.localizedDescription ?? "Could not connect to server. Check your network and try again later.",
                            action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                        )
                        self.onShowError.accept(okAlert)
                    }
                )
                .disposed(by: self.bag)
        } else {
            self.isLoading.accept(false)
        }
    }
    
    private func fetchRealmDBData() -> Bool {
        self.isLoading.accept(true)
        if let posts = DatabaseManager.shared.getAllPostsFromRealm() {
            for post in posts {
                if let index = postArray.firstIndex(where: {$0.id == post.id}) {
                    postArray[index] = post
                } else {
                    self.postArray.append(post)
                }
            }
        }
        self.posts.accept(self.postArray)
        self.postArray.count == 0 ? isEmptyArray.accept(true): isEmptyArray.accept(false)
        self.isLoading.accept(false)
        return self.postArray.count == 0 ? false: true
    }
    
    private func checkAndUpdate(posts: [RPost]) {
        for i in 0..<posts.count {
            if isFavoritePost(posts[i]) {
                posts[i].isFavourite = true
            }
            DatabaseManager.shared.savePostInRealm(posts[i])
        }
        self.postArray = posts
        self.posts.accept(self.postArray)
    }
    
    func updateFavouriteStatus(on post: RPost) {
        if let favouritePosts = DatabaseManager.shared.getAllFavoritePost(), favouritePosts.contains(where: { $0.id == post.id }) {
            DatabaseManager.shared.updateFavouriteStatus(post.id , false)
        } else {
            DatabaseManager.shared.updateFavouriteStatus(post.id, true)
        }
        posts.accept(postArray)
        self.postArray.count == 0 ? isEmptyArray.accept(true): isEmptyArray.accept(false)
    }
    
    func isFavoritePost(_ post: RPost) -> Bool {
        guard let favouritePosts = DatabaseManager.shared.getAllFavoritePost() else { return false }
        return favouritePosts.contains(where: { $0.id == post.id }) ? true : false
    }
    
}
