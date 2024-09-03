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
    
    let favouritePosts = PublishRelay<[RPost]>()
    
    private let isLoading = BehaviorRelay(value: true)
    private let isEmptyArray = BehaviorRelay(value: true)
    private let bag = DisposeBag()
    
    private var favouritePostArray = [RPost]()
    
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
    
    func fetchFavouritePosts() {
        self.isLoading.accept(true)
        self.favouritePostArray = []
        if let posts = DatabaseManager.shared.getAllFavoritePost() {
            for post in posts {
                self.favouritePostArray.append(post)
            }
        }
        self.isLoading.accept(false)
        self.favouritePosts.accept(self.favouritePostArray)
        self.favouritePostArray.count == 0 ? isEmptyArray.accept(true): isEmptyArray.accept(false)
    }
    
    func removeFavouritePost(_ post: RPost) {
        DatabaseManager.shared.updateFavouriteStatus(post.id, false)
        favouritePostArray.removeAll(where: { $0.id == post.id })
        favouritePosts.accept(favouritePostArray)
        self.favouritePostArray.count == 0 ? isEmptyArray.accept(true): isEmptyArray.accept(false)
    }
    
}
