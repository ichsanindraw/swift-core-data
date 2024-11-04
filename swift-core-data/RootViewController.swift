//
//  RootViewController.swift
//  swift-core-data
//
//  Created by Ichsan Indra Wahyudi on 04/11/24.
//

import Foundation
import UIKit

class RootViewController: UIViewController {
    private let tableView: UITableView = {
        let view = UITableView()
        return view
    }()
    
    private let context = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
    private var datas: [ToDoListItem] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Swift Core Data"
        
        view.backgroundColor = .white
        
        setupNavigation()
        setupTable()
        setupUI()
        
        getAllItems()
    }
    
    private func setupNavigation() {
        let appearance = UINavigationBarAppearance()
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(handleAddItem)
        )
    }
    
    @objc private func handleAddItem() {
        let alert = UIAlertController(title: "Add Item", message: "Please add your item", preferredStyle: .alert)
        
        alert.addTextField()
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .destructive)
        let submitAction = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let textfield = alert.textFields?.first, let text = textfield.text, !text.isEmpty else {
                return
            }
            self?.addItem(name: text)
        }
        
        
        alert.addAction(cancleAction)
        alert.addAction(submitAction)
        
        
        present(alert, animated: true)
    }
    
    private func handleUpdateItem(item: ToDoListItem) {
        let alert = UIAlertController(title: "Edit Item", message: nil, preferredStyle: .alert)
        
        alert.addTextField()
        alert.textFields?.first?.text = item.name
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .destructive)
        let submitAction = UIAlertAction(title: "Edit", style: .default) { [weak self] _ in
            guard let textfield = alert.textFields?.first, let text = textfield.text, !text.isEmpty else {
                return
            }
            self?.updatedItem(item: item, newName: text)
        }
        
        
        alert.addAction(cancleAction)
        alert.addAction(submitAction)
        
        
        present(alert, animated: true)
    }
    
    private func handleDeleteItem(item: ToDoListItem) {
        let alert = UIAlertController(title: "Delete Item", message: "Are you sure want to delete the item?", preferredStyle: .alert)
        
        let cancleAction = UIAlertAction(title: "Cancel", style: .cancel)
        let submitAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteItem(item: item)
        }
        
        alert.addAction(cancleAction)
        alert.addAction(submitAction)
        
        present(alert, animated: true)
    }

    
    private func setupTable() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func setupUI() {
        view.addSubview(tableView)
        
        tableView.frame = view.bounds
    }
    
    private func getAllItems() {
        guard let context else { return }
        
        do {
            datas = try context.fetch(ToDoListItem.fetchRequest())
        } catch {
            
        }
    }
    
    private func addItem(name: String) {
        guard let context else { return }
        
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        
        do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
    
    private func deleteItem(item: ToDoListItem) {
        guard let context else { return }
        
        context.delete(item)
        
        do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
    
    private func updatedItem(item: ToDoListItem, newName: String) {
        guard let context else { return }
        
        item.name = newName
        
        do {
            try context.save()
            getAllItems()
        } catch {
            
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = datas[indexPath.row].name
        return cell
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(style: .normal, title: "Edit") {  [weak self] contextualAction, view, boolValue in
            guard let self else { return }
            
            self.handleUpdateItem(item: self.datas[indexPath.row])
        }

        return UISwipeActionsConfiguration(actions: [editAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] contextualAction, view, boolValue in
            guard let self else { return }
            
            self.handleDeleteItem(item: self.datas[indexPath.row])
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
