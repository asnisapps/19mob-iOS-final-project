//
//  ComprasTableViewController.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 04/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import CoreData

class ComprasTableViewController: UITableViewController {

    //Criando label que será a mensagem caso não tenham compras cadastradas
    var label = UILabel(frame: CGRect(x: 0, y:0, width: 200, height: 22))
    
    //Criando o objeto que fará requisições ao contexto, realizando solicitações ao entities criados
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Definindo o texto e alinhamento da label
        label.text = "Sua lista está vazia!"
        label.textAlignment = .center
        
        //Carregando a lista de compras
        loadProducts()
    }
    
    func loadProducts() {
        //Criando um objeto de requisição que será feita através da fetchedResultController
        //Essa request pode ser criada a partir do método da própria model
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        //Definindo o tipo de ordenação da busca. Aqui, definimos ordenação ascendente por name
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true )
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Instanciando NSFetchedResultsController, passando as informações de fetchRequest
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        //Definimos nossa ComprasTableViewController como delegate da fetchedRèsultController
        fetchedResultController.delegate = self
        do {
            //Executando a requisição
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "edit" {
            if let vc = segue.destination as? CompraViewController {
                vc.product = fetchedResultController.object(at: tableView.indexPathForSelectedRow!)
            }
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //Caso existam objetos recuperados pela fetchedResultController, preparamos a tableView
        if let count = fetchedResultController.fetchedObjects?.count {
            tableView.backgroundView = count == 0 ? label : nil
            return count
        } else {
            tableView.backgroundView = label
            return 0
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as?
            CompraTableViewCell else {
            return UITableViewCell()
        }

        //Recuperando da fetchedResultController o produto referente à célula
        let product  = fetchedResultController.object(at: indexPath)
        cell.prepare(with: product)
        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let product = fetchedResultController.object(at: indexPath)
            
            //Excluindo o produto do contexto
            context.delete(product)
            
            do {
                //Persistindo a exclusão
                try context.save()
            } catch {
                print(error.localizedDescription)
            }
        }
          
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

//Implementando o protocolo NSFetchedResultsControllerDelegate
extension ComprasTableViewController: NSFetchedResultsControllerDelegate {
    
    //Método que é chamado sempre que uma alteração é feita no contexto
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.reloadData()
    }
}
