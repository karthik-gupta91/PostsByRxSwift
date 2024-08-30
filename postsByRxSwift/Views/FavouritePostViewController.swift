//
//  FavouritePostViewController.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 29/08/24.
//

import UIKit
import RxSwift
import PKHUD

class FavouritePostViewController: UIViewController {

    @IBOutlet weak var favouriteTableView: UITableView!
    
    private let bag = DisposeBag()
    private let viewModel = FavouriePostVM()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.title = Constants.Titles.favouritePosts
        
        favouriteTableView.register(UINib(nibName: Constants.NibName.postTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.postTableViewCell)
        
        subscribeLoadingHud()
        bindFavouriteTableData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchFavouritePosts()
    }

    private func bindFavouriteTableData() {
        
        viewModel.favouritePosts.bind(
            to: favouriteTableView.rx.items(
            cellIdentifier: Constants.CellIdentifier.postTableViewCell,
            cellType: PostTableViewCell.self)
        ) { (row, post, cell) in
            cell.configureCell(post, true)
        }.disposed(by: bag)
        
        favouriteTableView.rx.modelSelected(Post.self).bind{ post in
            self.viewModel.removeFavouritePost(post)
            if let selectedIndex = self.favouriteTableView.indexPathForSelectedRow {
                self.favouriteTableView.deselectRow(at: selectedIndex, animated: true)
            }
        }.disposed(by: bag)
        
    }
    
    private func subscribeLoadingHud() {
        viewModel
            .onShowLoadingHud
            .map { [weak self] in self?.setLoadingHud(visible: $0) }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func setLoadingHud(visible: Bool) {
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        visible ? PKHUD.sharedHUD.show(onView: view) : PKHUD.sharedHUD.hide()
    }

}
