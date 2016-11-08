//
//  TasksTVC.swift
//  Zbtn
//
//  Created by Azamat Kushmanov on 11/4/16.
//  Copyright © 2016 Azamat Kushmanov. All rights reserved.
//

import UIKit
import RealmSwift

struct Status {
    static let started = "started"
    static let stopped = "stopped"
    static let completed = "completed"
}

class TasksTVC: UITableViewController {

    var activeTasksnotificationToken: NotificationToken? = nil
    var completedTasksNotificationToken: NotificationToken? = nil
    var completedTasksIsHidden:Bool = true
    var activeTasks:Results<Task>? = nil
    var completedTasks:Results<Task>? = nil
    let startedTasksPredicate = NSPredicate(format: "status = %@", Status.started)
    
    var timer:Timer?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.estimatedRowHeight = 200
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = .none
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "tasks_background"))
        
        let realm = try! Realm()
        print("realm path: \(realm.configuration.fileURL?.absoluteString)")
        
        let activeTasksPredicate = NSPredicate(format: "status = %@ OR status = %@", Status.started, Status.stopped)
        let completedTasksPredicate = NSPredicate(format: "status = %@", Status.completed)
        
        
        activeTasks = realm.objects(Task.self).filter(activeTasksPredicate)
        completedTasks = realm.objects(Task.self).filter(completedTasksPredicate)
        
        activeTasksnotificationToken = activeTasks?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.tableView.reloadData()
        }
        
        completedTasksNotificationToken = completedTasks?.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            self?.tableView.reloadData()
        }
        
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerTick), userInfo: nil, repeats: true)
    }
    
    func timerTick(){
        let realm = try! Realm()
        
        if let currentStartedTask = realm.objects(Task.self).filter(self.startedTasksPredicate).first {
            if let index = self.activeTasks?.index(of: currentStartedTask){
                if let cell = self.tableView.cellForRow(at: IndexPath(row: index, section: 0)) {
                    (cell as! TaskCell).timeLabel.text = currentStartedTask.getTotalTimeString()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        return (section == 0 ? self.activeTasks?.count : completedTasksIsHidden ? 0 : self.completedTasks?.count)!
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell

        cell.initCardView()
        cell.checkboxButton.tag = indexPath.row
        cell.startStopButton.tag = indexPath.row
        
        switch indexPath.section {
        case 0:
            let task = self.activeTasks?[indexPath.row]
            
            cell.startStopButton.setImage(UIImage(named: task?.status == "stopped" ? "start_button" : "pause_button"), for: .normal)
            cell.startStopButton.isEnabled = true;
            cell.startStopButton.addTarget(self, action: #selector(startOrStopTask(sender:)), for: .touchUpInside)
            
            cell.checkboxButton.setImage(UIImage(named: "checkbox"), for: .normal)
            cell.checkboxButton.setImage(UIImage(named: "checkbox_filled"), for: .highlighted)
            cell.checkboxButton.addTarget(self, action: #selector(completeTask(sender:)), for: .touchUpInside)
            
            if task?.status == Status.started{
                cell.cardView.backgroundColor = UIColor.white
                cell.rightView.backgroundColor = UIColor.white
                cell.cardView.alpha = 1.0
            }
            
            cell.taskTitle.text = task?.title
            cell.timeLabel.text = task?.getTotalTimeString()
            break
        case 1:
            let task = self.completedTasks?[indexPath.row]
            
            cell.startStopButton.setImage(UIImage(named: "start_button"), for: .normal)
            cell.startStopButton.isEnabled = false;
            
            cell.checkboxButton.setImage(UIImage(named: "checkbox_filled"), for: .normal)
            cell.checkboxButton.setImage(UIImage(named: "checkbox"), for: .highlighted)
            cell.checkboxButton.addTarget(self, action: #selector(uncompleteTask(sender:)), for: .touchUpInside)
            
            cell.taskTitle.attributedText = self.getStrikedString(text: (task?.title)!);
            cell.timeLabel.text = task?.getTotalTimeString()
            
            break
        default:
            break
        }
        
        
        return cell;
    }
    
    func getStrikedString(text:String) -> NSAttributedString{
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: text)
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 2, range: NSMakeRange(0, attributeString.length))
        
        return attributeString;
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return nil;
        }
        
        let headerView = tableView.dequeueReusableCell(withIdentifier: "headerCell" ) as! HeaderView
        
        headerView.showHideCompletedTasksButton.tag = completedTasksIsHidden ? 0 : 1;
        headerView.initHeaderView()
        headerView.showHideCompletedTasksButton.addTarget(self, action: #selector(showOrHideCompletedTasks(sender:)), for: .touchUpInside)
        headerView.tag = -5;
        
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let task = indexPath.section == 0 ? self.activeTasks?[indexPath.row] : self.completedTasks?[indexPath.row] {
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            optionMenu.addAction(UIAlertAction(title: "Изменить", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                
                let alertController = UIAlertController(title: "Изменить задачу \(task.title)", message: "Введите новое название задачи", preferredStyle: .alert)
                
                let addAction = UIAlertAction(title: "Изменить", style: .default) { (_) in
                    let textField = alertController.textFields![0] as UITextField
                    
                    let realm = try! Realm()
                    
                    try! realm.write {
                        task.title = textField.text!
                    }
                }
                
                addAction.isEnabled = false
                
                let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
                
                alertController.addTextField { (textField) in
                    textField.placeholder = "Новое название задачи"
                    textField.text = task.title
                    
                    NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                        addAction.isEnabled = !self.checkTaskExist(taskTitle: textField.text!) && textField.text != ""
                    }
                }
                
                alertController.addAction(addAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true) {
                    // ...
                }
            }))
            
            optionMenu.addAction(UIAlertAction(title: "Удалить", style: .destructive, handler: {
                (alert: UIAlertAction!) -> Void in
                let realm = try! Realm()
                
                try! realm.write {
                    realm.delete(task)
                }
            }))
            
            optionMenu.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                
            }))
            
            
            self.present(optionMenu, animated: true, completion: nil)
        }
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
    
    func startOrStopTask(sender: UIButton!) {
        let task = self.activeTasks?[sender.tag]
        let realm = try! Realm()
        
        if let currentStartedTask = realm.objects(Task.self).filter(self.startedTasksPredicate).first {
            if currentStartedTask.id != task?.id{
                self.stopSession(task: currentStartedTask)
            }
        }
        
        task?.status == Status.started ? self.stopSession(task: task!) : self.startSession(task: task!)
    }
    
    func startSession(task:Task){
        let session = Session()
        session.id = NSUUID().uuidString
        session.taskId = task.id;
        session.startTime = Date()
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(session, update: true)
            task.status = Status.started
        }
    }
    
    func stopSession(task:Task){
        let realm = try! Realm()
        let currentSessionPredicate = NSPredicate(format: "stopTime = nil AND taskId = %@",task.id)
        
        if let currentSession = realm.objects(Session.self).filter(currentSessionPredicate).first {
            try! realm.write {
                currentSession.stopTime = Date()
            }
        }
        
        try! realm.write {
            task.status = Status.stopped
        }
    }
    
    func completeTask(sender: UIButton!) {
        let task = self.activeTasks?[sender.tag]
        let realm = try! Realm()
        
        self.stopSession(task: task!)
        
        try! realm.write {
            task?.status = Status.completed
        }
    }
    
    func uncompleteTask(sender: UIButton!) {
        let task = self.completedTasks?[sender.tag]
        let realm = try! Realm()
        
        try! realm.write {
            task?.status = Status.stopped
        }
    }
    
    @IBAction func addTask(_ sender: Any) {
        
        let alertController = UIAlertController(title: "Добавить новую задачу", message: "Введите название задачи", preferredStyle: .alert)
        
        let addAction = UIAlertAction(title: "Добавить", style: .default) { (_) in
            let textField = alertController.textFields![0] as UITextField
            self.addNewTask(taskTitle: textField.text!)
        }
        
        addAction.isEnabled = false
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Название задачи"
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name.UITextFieldTextDidChange, object: textField, queue: OperationQueue.main) { (notification) in
                addAction.isEnabled = textField.text != "" && !self.checkTaskExist(taskTitle: textField.text!)
            }
        }
        
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true) {
            // ...
        }
    }
    
    func checkTaskExist(taskTitle:String) -> Bool{
        let realm = try! Realm()
        let predicate = NSPredicate(format: "title = %@",taskTitle)
        
        return realm.objects(Task.self).filter(predicate).count > 0
    }
    
    func addNewTask(taskTitle:String){
        let task = Task()
        task.id = NSUUID().uuidString
        task.title = taskTitle;
        task.status = Status.stopped
        
        let realm = try! Realm()
        
        try! realm.write {
            realm.add(task, update: true)
        }
    }
    
    deinit {
        activeTasksnotificationToken?.stop()
        completedTasksNotificationToken?.stop()
    }
    
    
    
    
    
    
    
    
    
}

