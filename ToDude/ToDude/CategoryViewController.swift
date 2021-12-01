//
//  CategoryViewController.swift
//  ToDude
//
//  Created by Muhammad Huzaifa Khalid on 2021-11-30.
//

import UIKit
import CoreData
import SwipeCellKit

class CategoryViewController: UITableViewController {

  let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
  
  var categories = [Category]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    loadCategories()
    
    tableView.rowHeight = 85.0
  }
  
  @IBAction func addCategoryButtonTapped(_ sender: UIBarButtonItem) {
    // we need this in order to access the text field data outside of the 'addTextField' scope below
    var tempTextField = UITextField()
    
    // create a UIAlertController object
    let alertController = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)
    
    // create a UIAlertAction object
    let alertAction = UIAlertAction(title: "Done", style: .default) { (action) in
      // create a new category from our Category core data entity (we pass it the context)
      let newCategory = Category(context: self.context)
      
      // if the text field text is not nil
      if let text = tempTextField.text {
        // set the category attributes
        newCategory.name = text
        
        // append the category to our categories array
        self.categories.append(newCategory)
        
        // call our saveCategories() method which saves our context and reloads the table
        self.saveCategories()
      }
    }
    
    alertController.addTextField { (textField) in
      textField.placeholder = "Name"
      tempTextField = textField
    }
    
    // Add the action we created above to our alert controller
    alertController.addAction(alertAction)
    // show our alert on screen
    present(alertController, animated: true, completion: nil)
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! SwipeTableViewCell
    cell.delegate = self
    
    let category = categories[indexPath.row]
    
    cell.textLabel?.text = category.name

    return cell
  }
  
    
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categories.count
  }
  
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      performSegue(withIdentifier: "showItems", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      // get the destination view controller (the place where the segue will take us)
      let destinationVC = segue.destination as! ItemListViewController
      
      // get the indexPath of the selected cell
      if let indexPath = tableView.indexPathForSelectedRow {
        // set the category propert on the destination view controller (ItemListViewController)
        destinationVC.category = categories[indexPath.row]
      }
    }

  func saveCategories() {
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
  
  func loadCategories() {
    // create a new fetch request of type NSFetchRequest<Category> - you must provide a type
    let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()
    
    // wrap our try statement below in a do/catch block so we can handle any errors
    do {
      // fetch our categories using our fetch request, save them in our categories array
      categories = try context.fetch(fetchRequest)
    } catch {
      print("Error fetching categories: \(error)")
    }
    
    // reload our table to reflect any changes
    tableView.reloadData()
  }
}

// MARK: SwipeTableViewCellDelegate Methods

extension CategoryViewController: SwipeTableViewCellDelegate {
  
  func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
    guard orientation == .right else { return nil }
    
    // initialize a SwipeAction object
    let deleteAction = SwipeAction(style: .destructive, title: "Delete") { _, indexPath in
      // delete the item from our context
      self.context.delete(self.categories[indexPath.row])
      // remove the item from the items array
      self.categories.remove(at: indexPath.row)
      
      // save our context
      self.saveCategories()
    }
    
    // customize the action appearance
    deleteAction.image = UIImage(named: "trash")
    
    return [deleteAction]
  }
  
}
