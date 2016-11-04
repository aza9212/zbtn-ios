//
//  TasksTVC.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/4/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit

class TasksTVC: UITableViewController {

    var completedTasksIsHidden:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "tasks_background"))    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0.0 : 50.0;
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0;
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 20 : completedTasksIsHidden ? 0 : 10
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell") as! TaskCell

        cell.initCardView()
        
        switch indexPath.section {
        case 0:
            cell.startStopButton.setImage(UIImage(named: "start_button"), for: .normal)
//            cell.taskTitle.text = "3"
            cell.timeLabel.text = "00:04:45"
            break
        case 1:
            cell.startStopButton.setImage(UIImage(named: "pause_button"), for: .normal)
            break
        default:
            break
        }
        
        return cell;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil;
        }
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell" ) as! HeaderView
        
        headerView.showHideCompletedTasksButton.tag = completedTasksIsHidden ? 0 : 1;
        headerView.initHeaderView()
        headerView.showHideCompletedTasksButton.addTarget(self, action: #selector(showOrHideCompletedTasks(sender:)), for: .touchUpInside)
        
        
        return headerView
    }
    
    func showOrHideCompletedTasks(sender: UIButton!) {
        if sender.tag == 0 {
            sender.tag = 1;
            completedTasksIsHidden = false
        }else{
            sender.tag = 0;
            completedTasksIsHidden = true;
        }
        
        self.tableView.reloadData()
    }
    
}

