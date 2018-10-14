//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Michael Gable on 10/2/18.
//  Copyright © 2018 Michael Gable. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework


class CategoryViewController: SwipeTableViewController {

    

    let realm = try! Realm()
    
    var categoryArray : Results<Category>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadCategories()
        tableView.separatorStyle = .none
        

    }


    @IBOutlet weak var addButtonPressed: UIBarButtonItem!
    

    @IBAction func addButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Add new Todo item", message: "", preferredStyle: .alert)
        
        var textField = UITextField()
        
        let action = UIAlertAction(title: "Add Category", style: .default) { (action) in
            
            let newCategory = Category()
            
            newCategory.name = textField.text!
            newCategory.color = UIColor.randomFlat.hexValue()
            
            self.saveCategory(category: newCategory)
            
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new category..."
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    //MARK: - Table View datasource methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    
    
    //MARK: - Table View delegate methods
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet."
        
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].color ?? "#1D9BF6")
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SwipeTableViewCell
//        cell.delegate = self
//        return cell
//    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "goToItems", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! TodoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categoryArray?[indexPath.row]
        }
    }
    
    
    
    
    //MARK: - Data manipulation methods
    
    func saveCategory(category: Category) {
        do{
            try realm.write {
                realm.add(category)
            }
        } catch{
            print("Error, could not save category, \(error)")
        }
            self.tableView.reloadData()
    }
    
    func loadCategories() {

        categoryArray = realm.objects(Category.self)
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
                if let category = self.categoryArray?[indexPath.row]{
                    do{
                        try self.realm.write {
                            self.realm.delete(category)
                        }
                    } catch {
                        print("Error deleting category, \(error)")
                    }
                }
    }
}

