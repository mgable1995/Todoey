//
//  ViewController.swift
//  Todoey
//
//  Created by Michael Gable on 9/25/18.
//  Copyright © 2018 Michael Gable. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    var toDoItems : Results<Item>?
    var selectedCategory: Category? {
        didSet{
            loadItems()
        }
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadItems()
        tableView.separatorStyle = .none

    }
    
    override func viewWillAppear(_ animated: Bool){
        
        guard let navBar = navigationController?.navigationBar else {
            fatalError("Navigation controller doesn't exist.")
        }
        
        guard let colorHex = selectedCategory?.color else { fatalError() }
            
            title = selectedCategory!.name
        
        guard let navBarColor = UIColor(hexString: colorHex) else { fatalError() }
                navBar.barTintColor = navBarColor
                navBar.tintColor = ContrastColorOf(navBarColor, returnFlat: true)
                navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ContrastColorOf(navBarColor, returnFlat: true)]
                searchBar.barTintColor = navBarColor
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let originalColor = UIColor(hexString: "1D9BF6") else { fatalError() }
        navigationController?.navigationBar.barTintColor = originalColor
        navigationController?.navigationBar.tintColor = FlatWhite()
        navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : FlatWhite()]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return toDoItems?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = toDoItems?[indexPath.row]{
            cell.textLabel?.text = item.title
        
            if let categoryColor = UIColor(hexString: selectedCategory?.color ?? "#ffffff"){
            
            if let color = categoryColor.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(toDoItems!.count)){
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.textLabel?.text = "No items added."
        }
        

        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if let item = toDoItems?[indexPath.row] {
            do {
            try realm.write {
                item.done = !item.done
            }
            } catch {
                print("Error saving done attribute on item, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    //MARK - Add new items
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Add new Todo item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in


            
            if let currentCategory = self.selectedCategory {

                
                do{
                    try self.realm.write {
                        let newItem = Item()
                        newItem.dateCreated = Date()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                }catch{
                    print("Error saving new item to category, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveItems(item : Item) {
        do{
            try realm.write {
                realm.add(item)
            }
        } catch{
            print("Error, could not save item, \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadItems() {

        toDoItems = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = toDoItems?[indexPath.row] {
            do{
            try realm.write {
                realm.delete(item)
            }
            } catch{
                print("Error deleting item, \(error)")
            }
        }
    }
}
//MARK: - Search bar methods
extension TodoListViewController: UISearchBarDelegate {
    //Refer to NSPredicate cheat sheet for help on querying
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        toDoItems = toDoItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: false)
        
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

