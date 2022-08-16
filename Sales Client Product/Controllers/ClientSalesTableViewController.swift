//
//  ClientTableViewController.swift
//  Sales Client Product
//
//  Created by Fábio Silva  on 14/08/2022.
//

import UIKit
import CoreData

class ClientSalesTableViewController: UITableViewController {
    
    var sales = [Sales]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedClient: Client? {
        didSet{
            loadSales()
        }
    }

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
        cell.textLabel?.text = sales[indexPath.row].saleID! + " " + sales[indexPath.row].productSR!.name! + " " + String(format: "%.2f", sales[indexPath.row].productSR!.price)+"€"
        
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
    
    func loadSales(with request: NSFetchRequest<Sales> = Sales.fetchRequest(), predicate: NSPredicate? = nil) {
        let clientPredicate = NSPredicate(format: "clientR.phone MATCHES %@", selectedClient!.phone!)
        // se nao for dado um filtro apenas filtrar pela categoria caso contrario filtrar pelo filtro dado e categoria
        if let adicionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [adicionalPredicate, clientPredicate])
        }else{
            request.predicate = clientPredicate
        }
        do{
            // colocar os dados que foram colocados no context com o request a cima no array
            sales = try context.fetch(request)
        } catch {
            print("error fetching data \(error)")
        }
        tableView.reloadData()
    }
    
}




