//
//  SecretTableViewCell.swift
//  SecretKeeper
//
//  Created by Jason Bissict on 8/31/16.
//  Copyright © 2016 Jay. All rights reserved.
//

import UIKit

class SecretTableViewCell: UITableViewCell {
    
    //MARK: Properties
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
