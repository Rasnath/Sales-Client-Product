//
//  ClientTableViewController.swift
//  Sales Client Product
//
//  Created by Fábio Silva  on 14/08/2022.
//

import UIKit
import CoreData

class ProductTableViewController: UITableViewController {
    
    var products = [Product]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadProducts()
        
    }

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.cellForProduct, for: indexPath)
        
        cell.textLabel?.text = products[indexPath.row].name! + " " + String(format: "%.2f", products[indexPath.row].price)+"€"
        
        return cell
    }
    
    //MARK: - add Products

    @IBAction func addButtonP(_ sender: UIBarButtonItem) {
        
        var nameTextField = UITextField()
        var priceTextField = UITextField()
        
        
        let alert = UIAlertController(title: "New Product", message: "", preferredStyle: .alert)
        
        alert.addTextField { name in
            name.autocapitalizationType = .words
            name.placeholder = "Name:"
            nameTextField = name
        }
        alert.addTextField { price in
            price.keyboardType = .decimalPad
            price.placeholder = "Price:"
            priceTextField = price
        }
        
        let action = UIAlertAction(title: "Add Product", style: .default) { action in
            let newProduct = Product(context: self.context)
            newProduct.name = nameTextField.text
            newProduct.price = priceTextField.text?.doubleValue ?? 0
            self.products.append(newProduct)
            self.saveProduct()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Save and Load
    
    func saveProduct() {
        do{
            try self.context.save()
        } catch {
            print("error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadProducts(with request: NSFetchRequest<Product> = Product.fetchRequest()) {
        do{
            products = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - UISearchBarDelegate

extension ProductTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Product> = Product.fetchRequest()
        
        let predicate1 = NSPredicate(format: "name contains[cd] %@", searchBar.text!)
        let predicate2 = NSPredicate(format: "price contains %@", searchBar.text!)

        let predicateOr = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2])
        request.predicate = predicateOr
        loadProducts(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadProducts()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}

extension String {
    static let numberFormatter = NumberFormatter()
    var doubleValue: Double {
        String.numberFormatter.decimalSeparator = "."
        if let result =  String.numberFormatter.number(from: self) {
            return result.doubleValue
        } else {
            String.numberFormatter.decimalSeparator = ","
            if let result = String.numberFormatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
