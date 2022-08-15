//
//  ClientTableViewController.swift
//  Sales Client Product
//
//  Created by Fábio Silva  on 14/08/2022.
//

import UIKit
import CoreData

class SalesTableViewController: UITableViewController {
    
    var sales = [Sales]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSales()
     
    }
    

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sales.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.cellForSales, for: indexPath)
        cell.textLabel?.text = sales[indexPath.row].saleID! + " " + sales[indexPath.row].clientR!.firstName! + " " + sales[indexPath.row].productSR!.name!
        
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.context.delete(sales[indexPath.row])
            sales.remove(at: indexPath.row)
            saveSales()
        }
    }
    
    
    //MARK: - Save and Load
    
    func saveSales() {
        do{
            try self.context.save()
        } catch {
            print("error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadSales(with request: NSFetchRequest<Sales> = Sales.fetchRequest()) {
        do{
            sales = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
        tableView.reloadData()
    }
    
}


