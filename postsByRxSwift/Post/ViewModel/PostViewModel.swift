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
    
    let posts = PublishSubject<[Post]>()
    let favouritePosts = PublishSubject<[Post]>()
    
    let onShowError = PublishSubject<SingleButtonAlert>()
    
    private let isLoading = BehaviorRelay(value: false)
    private var apiClient: ApiClient
    private let bag = DisposeBag()
    
    private var favouritePostArray = Posts()
    private var postArray = Posts()
    
    var onShowLoadingHud: Observable<Bool> {
        return isLoading
            .asObservable()
            .distinctUntilChanged()
    }
    
    init(apiClient: ApiClient = ApiClient()) {
        self.apiClient = apiClient
    }
    
    func fetchPosts() {
        self.isLoading.accept(true)
        
        if let cdPosts = CDPost.getAllPostsFromCD() {
            for cdPost in cdPosts {
                let dict = cdPost.toDict()
                self.addCDSavedData(dict: dict)
            }
            self.isLoading.accept(false)
            self.posts.onNext(self.postArray)
            self.favouritePosts.onNext(self.favouritePostArray)
        }
        
        if Reachability.isConnectedToNetwork() {
            self.isLoading.accept(true)
            apiClient
                .fetchPosts()
                .subscribe(
                    onNext: { [weak self] posts in
                        guard let self = self else { return }
                        guard posts.count > 0 else {
                            self.postArray = []
                            self.posts.onNext(postArray)
                            CDPost.deleteObject(in: CoreDataManager.manager.manageObjectcontext)
                            return
                        }
                        CDPost.deleteObject(in: CoreDataManager.manager.manageObjectcontext)
                        for i in 0..<posts.count {
                            let cdPost = CDPost.getNewObject()
                            cdPost.savePostInCD(post: posts[i])
                            if isFavoritePost(posts[i]) {
                                CDPost.updatePostInCD(posts[i].id, true)
                            }
                        }
                        self.postArray = posts
                        self.isLoading.accept(false)
                        self.posts.onNext(self.postArray)
                    },
                    onError: { [weak self] error in
                        guard let self = self else { return }
                        self.isLoading.accept(false)
                        let okAlert = SingleButtonAlert(
                            title: "Alert",
                            message: (error as? ApiError)?.localizedDescription ?? "Could not connect to server. Check your network and try again later.",
                            action: AlertAction(buttonTitle: "OK", handler: { print("Ok pressed!") })
                        )
                        self.onShowError.onNext(okAlert)
                    }
                )
                .disposed(by: bag)
        } else {
            self.isLoading.accept(false)
        }
        
    }
    
    func addRemoveFavouritePost(_ post: Post) {
        if favouritePostArray.contains(where: { localPost in
            localPost.id == post.id
        }) {
            favouritePostArray.removeAll { localPost in
                localPost.id == post.id
            }
            CDPost.updatePostInCD(post.id, false)
        } else {
            favouritePostArray.append(post)
            CDPost.updatePostInCD(post.id, true)
        }
        
        favouritePosts.onNext(favouritePostArray)
        posts.onNext(postArray)
    }
    
    func isFavoritePost(_ post: Post) -> Bool {
        if favouritePostArray.contains(where: { localPost in
            localPost.id == post.id
        }) {
            return true
        }
        return false
    }
    
    func addCDSavedData(dict : [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let model = try JSONDecoder().decode(Post.self, from: data)
            
            self.postArray.append(model)
            
            if dict["isFavourite"] as? Bool == true {
                self.favouritePostArray.append(model)
            }
        }
        catch{}
    }
}
