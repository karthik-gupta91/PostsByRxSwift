//
//  PostTableViewCell.swift
//  postsByRxSwift
//
//  Created by Kartik Gupta on 27/08/24.
//

import UIKit
import RxSwift

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var favBtn: UIButton!
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        favBtn.setTitle("", for: .normal)
        favBtn.isUserInteractionEnabled = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ post: RPost,_ isFavorite: Bool) {
        titleLabel.text = post.title.capitalized
        detailLabel.text = post.body.capitalized
        isFavorite ? favBtn.setImage(UIImage(systemName: "star.fill"), for: .normal) : favBtn.setImage(UIImage(systemName: "star"), for: .normal)
    }
    
}
