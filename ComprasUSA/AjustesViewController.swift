//
//  AjustesViewController.swift
//  ComprasUSA
//
//  Created by Filipe Walter Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import Foundation
import CoreData

var state1: State?


enum UserDefaultKeys: String {
    case dolar = "exchangeRate"
    case iof = "percIOF"
}


class AjustesViewController: UIViewController {

    let ud = UserDefaults.standard
    var statesArray: [State] = []
    var label = UILabel(frame: CGRect(x: 0, y:0, width: 200, height: 22))
    var fetchedResultsController: NSFetchedResultsController<State>!
    
    @IBOutlet weak var tfDolar1: UITextField!
    @IBOutlet weak var tfIof1: UITextField!
    @IBOutlet weak var tvTax: UITableView!
    @IBAction func btAddEstado(_ sender: UIButton) {
        
        showInputDialog(title: "Adicionar Estado",
                        
                        actionTitle: "Adicionar",
                        cancelTitle: "Cancelar",
                        inputPlaceholder1: "Nome do estado",
                        inputPlaceholder2:"Imposto",
                        inputKeyboardType: .default,
                        inputKeyboardType2: .decimalPad
                        
                        )
        { (input:String? ) in
            
            
            print("The new number is \(input ?? "")")
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
       
           tfDolar1.text = ud.string(forKey: UserDefaultKeys.dolar.rawValue)
           tfIof1.text = ud.string(forKey: UserDefaultKeys.iof.rawValue)
           
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tvTax.dataSource = self
        tvTax.delegate = self
        
        tfDolar1.delegate = self
        tfIof1.delegate = self
        
        loadState()
    }

    
    func loadState() {
        
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do{
            statesArray = try context.fetch(fetchRequest)
        }catch{
            print(error.localizedDescription)
        }
        try? fetchedResultsController.performFetch()
        

    }
    
}

extension AjustesViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
        
        let state = fetchedResultsController.object(at: indexPath)
        context.delete(state)
        
        try? context.save()
    }
}
}


extension AjustesViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
       
        //        if let count = fetchedResultsController.fetchedObjects?.count {
//            tableView.backgroundView = count == 0 ? label : nil
//            print ("pirir \(count)")
//            return count
//
//        } else {
//            tableView.backgroundView = label
//            return 0
//        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? EstadoTableViewCell else {
                return UITableViewCell()
            }

            let state = fetchedResultsController.object(at: indexPath)
            
            cell.prepare(with: state)

            return cell
    }
    
    
    
}


//extension AjustesViewController: NSFetchedResultsControllerDelegate {
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//
//        tvTax.reloadData()
//
//    }
//
//
//}

extension AjustesViewController: NSFetchedResultsControllerDelegate{
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tvTax.reloadData()
    }
}


extension UIViewController {
    func showInputDialog(title:String? = nil,
                         subtitle:String? = nil,
                         actionTitle:String? = "Add",
                         cancelTitle:String? = "Cancel",
                         inputPlaceholder1:String? = nil,
                         inputPlaceholder2:String? = nil,
                         inputKeyboardType:UIKeyboardType = UIKeyboardType.default,
                         inputKeyboardType2:UIKeyboardType = UIKeyboardType.default,
                         cancelHandler: ((UIAlertAction) -> Swift.Void)? = nil,
                         actionHandler: ((  _ :String?) -> Void)? = nil) {

        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: .alert)
        alert.addTextField { (t1) in
            t1.placeholder = inputPlaceholder1
            t1.keyboardType = inputKeyboardType
        }
        
        alert.addTextField { (t2) in
            t2.placeholder = inputPlaceholder2
            t2.keyboardType = inputKeyboardType2
        }
        
        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: { (action:UIAlertAction) in
            guard let textField =  alert.textFields?.first else {
                actionHandler?(nil)
                return
            }
            guard let textField2 =  alert.textFields?.last else {
                actionHandler?(nil)
                
                return
            }
            
            print(textField.text)
            print(textField2.text)
            
            if state1 == nil {
                state1 = State(context: self.context)
                    }
            
            state1?.name = textField.text
            state1?.tax = NSDecimalNumber(string: textField2.text ?? "0.0")
                        
            try? self.context.save()           
            
            
            self.navigationController?.popViewController(animated: true)
            
            
         
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))

        self.present(alert, animated: true, completion: nil)
    }
}

extension AjustesViewController: UITextFieldDelegate {
     func textFieldShouldReturn(_ textField: UITextField) -> Bool {
         
        ud.set(tfDolar1.text!, forKey: UserDefaultKeys.dolar.rawValue)
        ud.set(tfIof1.text!, forKey: UserDefaultKeys.iof.rawValue)
         
        textField.resignFirstResponder()
        
        print(tfDolar1.text!)
        print(tfIof1.text!)
        
        return true
     }
 }
