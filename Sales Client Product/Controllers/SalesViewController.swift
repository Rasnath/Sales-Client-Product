//
//  ClientTableViewController.swift
//  Sales Client Product
//
//  Created by Fábio Silva  on 14/08/2022.
//

import UIKit
import CoreData

class SalesViewController: UIViewController {
    @IBOutlet weak var clientSeachBar: UISearchBar!
    @IBOutlet weak var productSearhBar: UISearchBar!
    @IBOutlet weak var clientTableView: UITableView!
    @IBOutlet weak var productsTableView: UITableView!
    
    var sales = [Sales]()
    var client = [Client]()
    var products = [Product]()
    
    var selectedClient: Client?
    var selectedProducts: Product?
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clientTableView.dataSource = self
        productsTableView.dataSource = self
        clientTableView.delegate = self
        productsTableView.delegate = self
        
        loadProducts()
        loadClients()
        loadSales()
        
        productsTableView.register(UITableViewCell.self, forCellReuseIdentifier: K.Cell.cellSalesProduct)
        clientTableView.register(UITableViewCell.self, forCellReuseIdentifier: K.Cell.cellSalesClient)
        
    }
    
    //MARK: - Save And Load
    
    func loadProducts(with request: NSFetchRequest<Product> = Product.fetchRequest()) {
        do{
            products = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
        productsTableView.reloadData()
    }
    
    func loadClients(with request: NSFetchRequest<Client> = Client.fetchRequest()) {
        do{
            client = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
        clientTableView.reloadData()
    }
    func loadSales(with request: NSFetchRequest<Sales> = Sales.fetchRequest()) {
        do{
            sales = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
    }
    func saveSales() {
        do{
            try self.context.save()
        } catch {
            print("error saving context \(error)")
        }
        navigationController?.popViewController(animated: true)
        dismiss(animated: true, completion: nil)
        
    }
    
    
    //MARK: - Sell Button
    
    @IBAction func doneButtonP(_ sender: UIButton) {
        
        if selectedClient != nil && selectedProducts != nil{
            let newSell = Sales(context: self.context)
            newSell.productSR = selectedProducts
            newSell.clientR = selectedClient
            
            var lastID : Int {
                if sales.isEmpty{
                    return 0
                } else {
                    let id = Int(sales.last!.saleID!)!
                    return id
                }
            }
            //            let year = Calendar.current.component(.year, from: Date())
            newSell.saleID = String(lastID + 1)
            newSell.date = Date()
            self.sales.append(newSell)
            self.saveSales()
        }
    }
}


//MARK: - UITableViewDataSource

extension SalesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == clientTableView {
            return client.count
        } else {
            return products.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == clientTableView{
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.cellSalesClient, for: indexPath)
            cell.textLabel?.text = client[indexPath.row].firstName! + " " + client[indexPath.row].lastName! + " " + client[indexPath.row].phone!
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.cellSalesProduct, for: indexPath)
            cell.textLabel?.text = products[indexPath.row].name! + " " + String(products[indexPath.row].price)
            return cell
        }
    }
}

//MARK: - UITableViewDelegate

extension SalesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch tableView {
        case clientTableView:
            selectedClient = client[indexPath.row]
        default:
            selectedProducts = products[indexPath.row]
        }
        
    }
}

//MARK: - UISearchBarDelegate

extension SalesViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        switch searchBar {
        case clientSeachBar:
            let request : NSFetchRequest<Client> = Client.fetchRequest()
            let predicate1 = NSPredicate(format: "firstName contains[cd] %@", clientSeachBar.text!)
            let predicate2 = NSPredicate(format: "lastName contains[cd] %@", clientSeachBar.text!)
            let predicate3 = NSPredicate(format: "phone contains %@", clientSeachBar.text!)
            let predicateOr = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2, predicate3])
            request.predicate = predicateOr
            loadClients(with: request)
            clientSeachBar.resignFirstResponder()
        default:
            let request : NSFetchRequest<Product> = Product.fetchRequest()
            let predicate1 = NSPredicate(format: "name contains[cd] %@", searchBar.text!)
            let predicate2 = NSPredicate(format: "price contains %@", searchBar.text!)
            let predicateOr = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2])
            request.predicate = predicateOr
            loadProducts(with: request)
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            switch searchBar {
            case clientSeachBar:
                loadClients()
            default:
                loadProducts()
            }
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
}









