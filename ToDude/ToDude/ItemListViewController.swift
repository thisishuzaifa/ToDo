//
//  ItemListViewController.swift
//  ToDude
//
//  Created by Muhammad Huzaifa Khalid on 2021-11-30.
//

import UIKit
import CoreData
import SwipeCellKit

class ItemListViewController: UITableViewController, SwipeTableViewCellDelegate, UISearchBarDelegate {
    
    var items = [Item]()
    var category: Category?
    
    @IBAction func addButtonTapped(_ sender: Any) {
        // we need this in order to access the text field data outside of the 'addTextField' scope below
        var tempTextField = UITextField()
        // create a UIAlertController object
        let alertController = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        // create a UIAlertAction object
        let alertAction = UIAlertAction(title: "Done", style: .default) { (action) in
        // create a new item from our Item core data entity (we pass it the context)
        let newItem = Item(context: self.context)
        // if the text field text is not nil
        if let text = tempTextField.text {
        // set the item attributes
        newItem.name = text
        newItem.category = self.category
        newItem.completed = false
        // append the item to our items array
        self.items.append(newItem)
        // call our saveItems() method which saves our context and reloads the table
        self.saveItems()
        }
        }
        alertController.addTextField { (textField) in
        textField.placeholder = "Title"
        tempTextField = textField
        }
        // Add the action we created above to our alert controller
        alertController.addAction(alertAction)
        // show our alert on screen
        present(alertController, animated: true, completion: nil)
        }
        func saveItems() {
        // wrap our try statement below in a do/catch block so we can handle any errors
        do {
        // save our context
        try context.save()
        } catch {
        print("Error saving context \(error)")
        }
        // reload our table to reflect any changes
        tableView.reloadData()
    }
    func loadItems() {
        // create a new fetch request of type NSFetchRequest<Item> - you must provide a type
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        // a predicate allows us to create a filter or mapping for our items
        let predicate = NSPredicate(format: "category.name MATCHES %@", category?.name ?? "")
        fetchRequest.predicate = predicate
        // wrap our try statement below in a do/catch block so we can handle any errors
        do {
        // fetch our items using our fetch request, save them in our items array
        items = try context.fetch(fetchRequest)
        } catch {
        print("Error fetching items: \(error)")
        }
        // reload our table to reflect any changes
        tableView.reloadData()
    }
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadItems()
        tableView.rowHeight = 85.0
 
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell", for: indexPath) as! SwipeTableViewCell
            cell.delegate = self
            let item = items[indexPath.row]
            cell.textLabel?.text = item.name
            cell.accessoryType = item.completed ? .checkmark : .none
    return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let item = items[indexPath.row]
    // toggle completed
    item.completed = !item.completed
    saveItems()
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    // initialize a SwipeAction object
    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
    // delete the item from our context
    self.context.delete(self.items[indexPath.row])
    // remove the item from the items array
    self.items.remove(at: indexPath.row)
    // save our context
    self.saveItems()
    }
    // customize the action appearance
    deleteAction.title = "Delete"
    return [deleteAction]
    }
    
    // this method's use is restricted to this file
    fileprivate func searchItems(searchText: String) {
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        // a predicate allows us to create a filter or mapping for our items
        // [c] means ignore case
        let titlePredicate = NSPredicate(format: "title CONTAINS[c] %@", searchText)
        let categoryPredicate = NSPredicate(format: "category.name MATCHES %@", category?.name ?? "")
        // a compound predicate allows you to combine multiple predicates on the same request
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate, titlePredicate])
        // the sort descriptor allows us to tell the request how we want our data sorted
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        // set the predicate and sort descriptors for on the request
        fetchRequest.predicate = compoundPredicate
        fetchRequest.sortDescriptors = [sortDescriptor]
        // retrieve the items with the request we created
        do {
        items = try context.fetch(fetchRequest)
        } catch {
        print("Error fetching items: \(error)")
        }
        // reload our table with our new data
        tableView.reloadData()
    }
    

}


