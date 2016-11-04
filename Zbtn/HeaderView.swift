//
//  HeaderView.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/5/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit

class HeaderView: UITableViewCell {

    @IBOutlet weak var showHideCompletedTasksButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func initHeaderView(){
        self.showHideCompletedTasksButton.layer.cornerRadius = 10.0;
        self.showHideCompletedTasksButton.layer.masksToBounds = true;
        self.showHideCompletedTasksButton.layer.borderWidth = 0.3;
        
        if self.showHideCompletedTasksButton.tag == 0{
            self.showHideCompletedTasksButton.setTitle("Показать завершенные задачи", for: .normal)
        }else{
            self.showHideCompletedTasksButton.setTitle("Скрыть завершенные задачи", for: .normal)
        }
    }
}
