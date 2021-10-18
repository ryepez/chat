//
//  ChatTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 9/27/21.
//

import UIKit

class ChatTableViewCell: UITableViewCell {

    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var imageViewMessage: UIImageView!
    
    @IBOutlet weak var messageStackView: UIStackView!
    @IBOutlet weak var message: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        
    }
    
    

}
