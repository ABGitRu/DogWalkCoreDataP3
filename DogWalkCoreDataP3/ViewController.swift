//
//  ViewController.swift
//  DogWalkCoreDataP3
//
//  Created by Mac on 20.06.2021.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    private let cellId = "cellId"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        return tableView
    }()
    
    lazy var coreDataStack = CoreDataStack(modelName: "DogWalk")
    
    var currentDog: Dog?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData()
        setupViews()
    }
    
    private func fetchData() {
        let dogName = "Fido"
        let dogFetch: NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name), dogName)
        
        do {
            let results = try coreDataStack.managedContext.fetch(dogFetch)
            if results.isEmpty {
                currentDog = Dog(context: coreDataStack.managedContext)
                currentDog?.name = dogName
                coreDataStack.saveContext()
            } else {
                currentDog = results.first
            }
        } catch let error {
            print(error)
        }
    }
    
    private func setupViews() {
        view.addSubview(tableView)
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddButton))
        self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
    }
    
    @objc private func handleAddButton() {
        let walk = Walk(context: coreDataStack.managedContext)
        walk.date = Date()
        
        if let dog = currentDog,
           let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
        coreDataStack.saveContext()
        tableView.reloadData()
    }
    
}
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        currentDog?.walks?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        guard let walk = currentDog?.walks?[indexPath.row] as? Walk,
              let walkDate = walk.date as Date?  else { return cell }
        cell.textLabel?.text = dateFormatter.string(from: walkDate)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk,
              editingStyle == .delete else { return }
        
        coreDataStack.managedContext.delete(walkToRemove)
        
        coreDataStack.saveContext()
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    
}
