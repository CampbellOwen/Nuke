//
//  HeroTableViewCell.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-05-01.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import UIKit

class HeroTableViewCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var heroImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
