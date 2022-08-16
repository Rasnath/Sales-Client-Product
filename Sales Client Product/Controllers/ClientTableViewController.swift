//
//  ClientTableViewController.swift
//  Sales Client Product
//
//  Created by Fábio Silva  on 14/08/2022.
//

import UIKit
import CoreData

class ClientTableViewController: UITableViewController {
    
    var clients = [Client]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
        loadClients()
    }
  

    // MARK: - TableView data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Cell.cellForClient, for: indexPath)
        
        cell.textLabel?.text = clients[indexPath.row].firstName! + " " + clients[indexPath.row].lastName! + " " + clients[indexPath.row].phone!
        
        return cell
    }
    
    //MARK: - TableView Delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            self.context.delete(clients[indexPath.row])
            clients.remove(at: indexPath.row)
            saveClient()
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: K.Segue.clientToInfo, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ClientSalesTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedClient = clients[indexPath.row]
        }
    }
    
    //MARK: - add Clients

    @IBAction func addButtonP(_ sender: UIBarButtonItem) {
        
        var firstNameTextField = UITextField()
        var lastNameTextField = UITextField()
        var phoneTextField = UITextField()
        
        
        let alert = UIAlertController(title: "New Client", message: "", preferredStyle: .alert)
        
        alert.addTextField { firstName in
            firstName.autocapitalizationType = .words
            firstName.placeholder = "First name:"
            firstNameTextField = firstName
        }
        alert.addTextField { lastName in
            lastName.autocapitalizationType = .words
            lastName.placeholder = "Last name:"
            lastNameTextField = lastName
        }
        alert.addTextField { phone in
            phone.keyboardType = .numberPad
            phone.placeholder = "Phone:"
            phoneTextField = phone
        }
        
        let action = UIAlertAction(title: "Add Client", style: .default) { action in
            let newCliente = Client(context: self.context)
            newCliente.firstName = firstNameTextField.text
            newCliente.lastName = lastNameTextField.text
            newCliente.phone = phoneTextField.text
            self.clients.append(newCliente)
            self.saveClient()
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Save and Load
    
    func saveClient() {
        do{
            try self.context.save()
        } catch {
            print("error saving context \(error)")
        }
        self.tableView.reloadData()
    }
    
    func loadClients(with request: NSFetchRequest<Client> = Client.fetchRequest()) {
        do{
            clients = try context.fetch(request)
        } catch {
            print("error loading context \(error)")
        }
        tableView.reloadData()
    }
    
}

//MARK: - UISearchBarDelegate

extension ClientTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let request : NSFetchRequest<Client> = Client.fetchRequest()
        
        let predicate1 = NSPredicate(format: "firstName contains[cd] %@", searchBar.text!)
        let predicate2 = NSPredicate(format: "lastName contains[cd] %@", searchBar.text!)
        let predicate3 = NSPredicate(format: "phone contains %@", searchBar.text!)

        let predicateOr = NSCompoundPredicate(type: .or, subpredicates: [predicate1, predicate2, predicate3])
        request.predicate = predicateOr
        loadClients(with: request)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadClients()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
