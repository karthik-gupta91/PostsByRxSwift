//
//  PostViewController.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 26/08/24.
//

import UIKit
import RxSwift
import RxCocoa
import PKHUD

class PostViewController: UIViewController {
    
    @IBOutlet weak var postTableView: UITableView!
    
    private let bag = DisposeBag()
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.navigationItem.title = Constants.Titles.posts
        
        postTableView.register(UINib(nibName: Constants.NibName.postTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.postTableViewCell)
                
        subscribeLoadingHud()
        subscribeAlert()
        bindPostTableData()
        viewModel.fetchNetworkPosts()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchCDData()
    }
    
    private func bindPostTableData() {
        
        viewModel.posts.bind(
            to: postTableView.rx.items(
            cellIdentifier: Constants.CellIdentifier.postTableViewCell,
            cellType: PostTableViewCell.self)
        ) { [unowned self] (row, post, cell) in
            cell.configureCell(post, self.viewModel.isFavoritePost(post))
        }.disposed(by: bag)
        
        postTableView.rx.modelSelected(Post.self).bind{ [unowned self] post in
            self.viewModel.updateFavouriteStatus(on: post)
        }.disposed(by: bag)
        
    }
    
    private func subscribeAlert() {
        viewModel
            .onShowError
            .map { [weak self] in self?.presentSingleButtonDialog(alert: $0)}
            .subscribe()
            .disposed(by: bag)
        
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

extension PostViewController: SingleButtonDialogPresenter { }
