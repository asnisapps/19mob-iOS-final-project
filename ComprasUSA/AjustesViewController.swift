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
            
            //Também apagar todos os produtos com o mesmo state
            for product in state.products! {
                context.delete(product as! NSManagedObject)
            }
            
            try? context.save()
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tvTax.cellForRow(at: indexPath) as? EstadoTableViewCell else {
            return
        }
        
        
        
        showInputDialog(
            title: "Editar Estado",
            actionTitle: "Salvar",
            cancelTitle: "Cancelar",
            inputPlaceholder1: cell.lbState.text ,
            inputPlaceholder2: cell.lbTax.text,
            inputKeyboardType: .default,
            inputKeyboardType2: .decimalPad
            
        )
        
    }
}


extension AjustesViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
        
        
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
            
            let stateName = textField.text
            let decimalValue = textField2.text
            
            if self.validateNumber2(decimalValue) && self.validateText2(stateName) {
                
                let newState = State(context: self.context)
                
                newState.name = textField.text
                newState.tax = NSDecimalNumber(string: textField2.text ?? "0.0")
                
                try? self.context.save()
            } else {
                let alert = UIAlertController(title: "Valor Invalido", message: "Insira um valor valido", preferredStyle: .alert)

                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

                self.present(alert, animated: true)
            }
            
            self.navigationController?.popViewController(animated: true)
            
            actionHandler?(textField.text)
        }))
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: cancelHandler))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func validateNumber2(_ text: String?) -> Bool {
        guard let number = text else { return false }
            if number == nil || number == "" || number.isEmpty {
                return false
            }
        return number.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    func validateText2(_ text: String?) -> Bool {
        guard let message = text else { return false }
            if message == nil || message == "" || message.isEmpty {
                return false
            }
        return true
    }
}

extension AjustesViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        ud.set(tfDolar1.text!, forKey: UserDefaultKeys.dolar.rawValue)
        ud.set(tfIof1.text!, forKey: UserDefaultKeys.iof.rawValue)
        
        textField.resignFirstResponder()
        return true
    }
}
