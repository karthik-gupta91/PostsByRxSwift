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
    
    let posts = PublishRelay<[Post]>()
    let onShowError = PublishRelay<SingleButtonAlert>()
    
    private let isLoading = BehaviorRelay(value: true)
    private var apiClient: ApiClient
    private let bag = DisposeBag()
    
    private var postArray = Posts()
    
    var onShowLoadingHud: Observable<Bool> {
        return isLoading
            .asObservable()
            .distinctUntilChanged()
    }
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func fetchCDData() {
        self.isLoading.accept(true)
        if let cdPosts = CDPost.getAllPostsFromCD() {
            for cdPost in cdPosts {
                let dict = cdPost.toDict()
                self.addCDSavedData(dict: dict)
            }
        }
        self.posts.accept(self.postArray)
        self.isLoading.accept(false)
    }
    
    func fetchNetworkPosts() {
        self.isLoading.accept(true)
        if Reachability.isConnectedToNetwork() {
            self.apiClient
                .fetchPosts()
                .subscribe(
                    onNext: { [weak self] posts in
                        guard let self = self else { return }
                        guard posts.count > 0 else {
                            return
                        }
                        for i in 0..<posts.count {
                            CDPost.updatePostInCD(post: posts[i])
                        }
                        self.postArray = posts
                        self.posts.accept(self.postArray)
                        self.isLoading.accept(false)
                    },
                    onError: { [weak self] error in
                        guard let self = self else { return }
                        self.isLoading.accept(false)
                        let okAlert = SingleButtonAlert(
                            title: "Alert",
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
    
    func updateFavouriteStatus(on post: Post) {
        if let favouritePosts = CDPost.getAllFavoritePost(), favouritePosts.contains(where: { $0.id == post.id }) {
            CDPost.updateFavouriteStatus(post.id, false)
        } else {
            CDPost.updateFavouriteStatus(post.id, true)
        }
        posts.accept(postArray)
    }
    
    func isFavoritePost(_ post: Post) -> Bool {
        guard let favouritePosts = CDPost.getAllFavoritePost() else { return false }
        return favouritePosts.contains(where: { $0.id == post.id }) ? true : false
    }
    
    func addCDSavedData(dict : [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let model = try JSONDecoder().decode(Post.self, from: data)

            if let index = postArray.firstIndex(where: {$0.id == model.id}) {
                postArray[index] = model
            } else {
                self.postArray.append(model)
            }
        }
        catch{}
    }
    
}
