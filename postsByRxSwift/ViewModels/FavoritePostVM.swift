//
//  FavoritePostVM.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 29/08/24.
//

import Foundation
import RxSwift
import RxRelay

class FavouriePostVM {
    
    let favouritePosts = PublishSubject<[Post]>()
    let onShowError = PublishSubject<SingleButtonAlert>()
    
    private let isLoading = BehaviorRelay(value: false)
    private let bag = DisposeBag()
    
    private var favouritePostArray = Posts()
    
    var onShowLoadingHud: Observable<Bool> {
        return isLoading
            .asObservable()
            .distinctUntilChanged()
    }
    
    func fetchFavouritePosts() {
        self.isLoading.accept(true)
        self.favouritePostArray = []
        if let cdPosts = CDPost.getAllFavoritePost() {
            for cdPost in cdPosts {
                let dict = cdPost.toDict()
                self.addCDSavedData(dict: dict)
            }
        }
        self.isLoading.accept(false)
        self.favouritePosts.onNext(self.favouritePostArray)
    }
    
    func removeFavouritePost(_ post: Post) {
        CDPost.updateFavouriteStatus(post.id, false)
        favouritePostArray.removeAll(where: { $0.id == post.id })
        favouritePosts.onNext(favouritePostArray)
    }
    
    func addCDSavedData(dict : [String: Any]) {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let model = try JSONDecoder().decode(Post.self, from: data)
            
            self.favouritePostArray.append(model)
            
        }
        catch{}
    }
}
