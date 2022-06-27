//
//  TaskListViewController.swift
//  CoreDataDemo
//
//  Created by Alexey Efimov on 04.10.2021.
//

import UIKit

class TaskListViewController: UITableViewController {
    private let storeManager = StoreManager.shared
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        
        setupNavigationBar()
        fetchData()
    }

    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func addNewTask() {
        showCreatingTaskAlert(with: "Edit Task", and: "What do you want to do?")
    }
    
    private func showCreatingTaskAlert(with title: String, and message: String) {
        let alert = getBaseAlert(with: title, and: message)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty else { return }
            self.createTask(taskTitle)
        }
        alert.addAction(saveAction)
        
        present(alert, animated: true)
    }
    
    private func showEditingingTaskAlert(with title: String, and message: String, cellRowIndex: Int) {
        let task = taskList[cellRowIndex]
        let alert = getBaseAlert(with: title, and: message)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            guard let taskTitle = alert.textFields?.first?.text, !taskTitle.isEmpty else { return }
            self.editTask(task, newTitle: taskTitle)
        }
        alert.addAction(saveAction)
        
        if let textField = alert.textFields?.first {
            textField.text = task.title
        }
        
        present(alert, animated: true)
    }
    
    private func getBaseAlert(with title: String, and message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)

        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "Enter task text"
        }
        
        return alert
    }
    
    private func fetchData() {
        do {
            taskList = try storeManager.fetchTasks()
        } catch let error {
            print("Failed to fetch data", error)
        }
    }
    
    private func createTask(_ taskTitle: String) {
        storeManager.createTask(with: taskTitle) { task in
            self.taskList.append(task)
            
            let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        }
    }
    
    private func editTask(_ task: Task, newTitle: String) {
        storeManager.editTask(task, newTitle: newTitle) {
            self.tableView.reloadData()
        }
    }
    
    private func removeTask(cellIndex: IndexPath) {
        let task = taskList[cellIndex.row]
        
        storeManager.removeTask(task) {
            self.taskList.remove(at: cellIndex.row)
            self.tableView.deleteRows(at: [cellIndex], with: .automatic)
        }
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showEditingingTaskAlert(with: "Edit Task",
                                and: "What do you want to do?",
                                cellRowIndex: indexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    override func tableView(_ tableView: UITableView,
                   trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    {
        let deleteAction = UIContextualAction(style: .normal, title:  "Delete", handler: { _, _, _ in
            self.removeTask(cellIndex: indexPath)
        })
        deleteAction.backgroundColor = .red

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
