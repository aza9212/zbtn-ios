//
//  TaskCell.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/4/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var taskTitle: UILabel!
    @IBOutlet weak var startStopButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var checkboxButton: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func initCardView(){
        self.cardView.layer.cornerRadius = 3.0;
        self.cardView.layer.masksToBounds = true;
        self.cardView.layer.borderWidth = 0.1;
    }

}
