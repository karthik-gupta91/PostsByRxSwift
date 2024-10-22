//
//  PostViewController.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import UIKit
import RxSwift
import RxCocoa

class PostViewController: UIViewController, Alert {
    
    @IBOutlet weak var postTableView: UITableView!
    
    @IBOutlet var noDataLabel: UILabel!
    
    private let bag = DisposeBag()
    private let viewModel = PostViewModel()
    private let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.title = Constants.Titles.posts
        
        postTableView.register(UINib(nibName: Constants.NibName.postTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.postTableViewCell)
        postTableView.refreshControl = refreshControl
        
        subscribeLoadingHud()
        subscribeAlert()
        subscribeEmptyView()
        bindPostTableData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchPosts()
    }
    
    private func bindPostTableData() {
        
        viewModel.posts.bind(
            to: postTableView.rx.items(
            cellIdentifier: Constants.CellIdentifier.postTableViewCell,
            cellType: PostTableViewCell.self)
        ) { [unowned self] (row, post, cell) in
            cell.configureCell(post, self.viewModel.isFavoritePost(post))
        }.disposed(by: bag)
        
        postTableView.rx.modelSelected(RPost.self).bind{ [unowned self] post in
            self.viewModel.updateFavouriteStatus(on: post)
        }.disposed(by: bag)
        
        postTableView.refreshControl?.rx.controlEvent(.valueChanged)
            .subscribe(onNext: { [weak self] in
                self?.viewModel.fetchNetworkPosts()
                self?.refreshControl.endRefreshing()
            })
            .disposed(by: bag)
    }
    
    private func subscribeAlert() {
        viewModel
            .onShowError
            .map { [weak self] in self?.showAlert(alert: $0)}
            .subscribe()
            .disposed(by: bag)
        
    }
    
    private func subscribeLoadingHud() {
        viewModel
            .onShowLoadingHud
            .map { [weak self] in self?.view.displayActivityIndicator(shouldDisplay: $0) }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func subscribeEmptyView() {
        viewModel
            .onShowEmptyView
            .map { [weak self] in self?.setNoView($0) }
            .subscribe()
            .disposed(by: bag)
    }
    
    private func setNoView(_ isEmpty: Bool) {
        self.noDataLabel.isHidden = !isEmpty
    }

}
