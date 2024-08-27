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
    
    let disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(_ post: Post,_ isFavorite: Bool) {
        titleLabel.text = post.title
        detailLabel.text = post.body
        backgroundColor = isFavorite ? .lightGray : .white
    }
    
}
