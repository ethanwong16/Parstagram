//
//  PostTableViewCell.swift
//  Parstagram
//
//  Created by Ethan Wong on 5/5/21.
//

import UIKit

class PostTableViewCell: UITableViewCell {
    
    /* don't name this imageView it will get confused! */
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
