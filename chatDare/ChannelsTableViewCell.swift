//
//  ChannelsTableViewCell.swift
//  chatDare
//
//  Created by Ramon Yepez on 10/11/21.
//

import UIKit

class ChannelsTableViewCell: UITableViewCell {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var lastMessageTimeWhie: UILabel!
    @IBOutlet weak var chatTittle: UILabel!
    @IBOutlet weak var dateOfLastmessage: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
