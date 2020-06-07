//
//  EstadoTableViewController.swift
//  ComprasUSA
//
//  Created by Filipe Walter Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import CoreData

class EstadoTableViewController: UITableViewController {

var fetchedResultsController: NSFetchedResultsController<State>!

override func viewDidLoad() {
    super.viewDidLoad()
    loadState()
}

func loadState() {
    
    let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
    let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
    fetchRequest.sortDescriptors = [sortDescriptor]
    
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    
    fetchedResultsController.delegate = self
    try? fetchedResultsController.performFetch()
    
    

}
     override func numberOfSections(in tableView: UITableView) -> Int {
            return 1
        }

        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return fetchedResultsController.fetchedObjects?.count ?? 0
        }


        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EstadoTableViewCell else {
                return UITableViewCell()
            }

            let state = fetchedResultsController.object(at: indexPath)
            
            cell.prepare(with: state)

            return cell
        }


        // Override to support editing the table view.
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                
                let movie = fetchedResultsController.object(at: indexPath)
                context.delete(movie)
                
                try? context.save()
                
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


    extension EstadoTableViewController: NSFetchedResultsControllerDelegate {
        func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
            
            tableView.reloadData()
            
        }
    }


