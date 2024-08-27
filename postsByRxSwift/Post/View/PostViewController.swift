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
    @IBOutlet weak var favouriteTableView: UITableView!
    @IBOutlet weak var segmentedCtrl: UISegmentedControl!
    
    
    private let bag = DisposeBag()
    private let viewModel = PostViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = Constants.Titles.posts
        navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.setHidesBackButton(true, animated: true)

        view.addSubview(postTableView)
        view.addSubview(favouriteTableView)
        
        registerCells()
        
        favouriteTableView.isHidden = true
        
        bindPostTableData()
        bindFavouriteTableData()
        subscribeLoadingHud()
        subscribeAlert()
        
        viewModel.fetchPosts()
        // Do any additional setup after loading the view.
    }
    
    private func registerCells() {
        postTableView.register(UINib(nibName: Constants.NibName.postTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.postTableViewCell)
        favouriteTableView.register(UINib(nibName: Constants.NibName.postTableViewCell, bundle: nil), forCellReuseIdentifier: Constants.CellIdentifier.postTableViewCell)
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
            self.viewModel.addRemoveFavouritePost(post)
            if let selectedIndex = self.postTableView.indexPathForSelectedRow {
                self.postTableView.deselectRow(at: selectedIndex, animated: true)
            }
        }.disposed(by: bag)
        
    }
    
    private func bindFavouriteTableData() {
        
        viewModel.favouritePosts.bind(
            to: favouriteTableView.rx.items(
            cellIdentifier: Constants.CellIdentifier.postTableViewCell,
            cellType: PostTableViewCell.self)
        ) { (row, post, cell) in
            cell.titleLabel?.text = post.title
            cell.detailLabel?.text = post.body
        }.disposed(by: bag)
        
        favouriteTableView.rx.modelSelected(Post.self).bind{ post in
            if let selectedIndex = self.favouriteTableView.indexPathForSelectedRow {
                self.favouriteTableView.deselectRow(at: selectedIndex, animated: true)
            }
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
    
    @IBAction func indexChanged(_ sender: Any) {
        switch segmentedCtrl.selectedSegmentIndex {
        case 0:
            postTableView.isHidden = false
            favouriteTableView.isHidden = true
        case 1:
            postTableView.isHidden = true
            favouriteTableView.isHidden = false
        default:
            break
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PostViewController: SingleButtonDialogPresenter { }
