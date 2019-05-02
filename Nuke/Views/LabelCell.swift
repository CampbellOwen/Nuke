//
//  LabelViewCell.swift
//  Nuke
//
//  Created by Owen Campbell on 2019-05-01.
//  Copyright © 2019 Owen Campbell. All rights reserved.
//

import UIKit

class LabelCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
