//
//  ProdutoViewController.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import CoreData

class CompraViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var tfProductName: UITextField!
    @IBOutlet weak var pvProductState: UIPickerView!
    @IBOutlet weak var tfProductValue: UITextField!
    @IBOutlet weak var swProductCard: UISwitch!
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var btProductSave: UIButton!
    
    var product: Product?
    var fetchedResultController: NSFetchedResultsController<State>!
    var statesArray: [State] = []
    var stateSelected: State?
    var alertText: Bool = false
    var alertNumber: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Carregando o vetor de estados
        loadStates()
        
        //Vinculando o UIPickerView a esta classe
        self.pvProductState.delegate = self
        self.pvProductState.dataSource = self
        
        //print(pvProductState.numberOfRows(inComponent: 0))

        if let product = product {
            tfProductName.text = product.name
            tfProductValue.text = "\(product.value ?? 0)"
            swProductCard.isOn = product.isCredit
            //guard let nameState = product.states else { return }
            //print("Nome do estado gravado no produto: \(nameState.name)")
            //guard let indexState = statesArray.index(of: nameState) else { return }
            //pvProductState.selectedRow(inComponent: indexState)
            //pvProductState.
            //pvProductState.dataSource = product.states as? UIPickerViewDataSource
            //pvProductState.selectedRow(inComponent: product.states.)
            print("Estado do produto a ser alterado: " + product.states!.name!)
            
            let stateRow: Int? = statesArray.firstIndex(of: product.states!)
            print("stateRow: \(stateRow!)")
            pvProductState.selectRow(stateRow!, inComponent: 0, animated: true)
            
            if let data = product.image {
                ivProductImage.image = UIImage(data: data)
            }
            btProductSave.setTitle("Alterar", for: .normal)
        }
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        ivProductImage.isUserInteractionEnabled = true
        ivProductImage.addGestureRecognizer(tapGestureRecognizer)
        
        tfProductName.delegate = self
        tfProductValue.delegate = self
        
        tfProductValue.addDoneCancelToolbar(onDone: (target: self, action: #selector(self.tapDone)), onCancel: (target: self, action: #selector(self.tapCancel)))
        
    }
    
    @objc func tapDone() {
        //print("tapped Done")
        tfProductValue.resignFirstResponder()
    }

    @objc func tapCancel() {
        //print("tapped cancel")        
        tfProductValue.resignFirstResponder()
    }
    
    //Retorna o número de componentes do picker view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Retorna o número de linhas por componente do picker view
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return statesArray.count
    }
    
    //Retorna qual dado será inserido em cada linha
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return statesArray[row].name
    }
    
    //Recupera o valor selecionado no picker view
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
        //print(row)
        //print(statesArray[row])
        stateSelected = statesArray[row]
        
        //print(pvProductState.numberOfRows(inComponent: 0))
    }
    
    
    func loadStates() {
        //Criando um objeto de requisição que será feita através da fetchedResultController
        //Essa request pode ser criada a partir do método da própria model
        let fetchRequest: NSFetchRequest<State> = State.fetchRequest()
        
        //Definindo o tipo de ordenação da busca. Aqui, definimos ordenação ascendente por name
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true )
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        //Instanciando NSFetchedResultsController, passando as informações de fetchRequest
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        //Definimos nossa CompraViewController como delegate da fetchedRèsultController
        fetchedResultController.delegate = self
        do {
            //Executando a requisição
            statesArray = try context.fetch(fetchRequest)
            //print(statesArray)
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        
        if let count = fetchedResultController.fetchedObjects?.count{
            //Caso existam estados
            if count > 0 && stateSelected == nil {
                //print("Selecionou estado default")
                
                //Seleciona o primeiro estado por padrão após carregar o
                stateSelected = statesArray[0]
            }
        }
        
    }
    
    func selectPicture(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }

    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        let tappedImage = tapGestureRecognizer.view as! UIImageView

        // Your action
        let alert = UIAlertController(title: "Selecionar poster", message: "De onde você quer escolher o poster?", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Câmera", style: .default) { (_) in
                self.selectPicture(sourceType: .camera)
            }
            alert.addAction(cameraAction)
        }
        
        let libraryAction = UIAlertAction(title: "Biblioteca de fotos", style: .default) { (_) in
            self.selectPicture(sourceType: .photoLibrary)
        }
        alert.addAction(libraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
                
        present(alert, animated: true, completion: nil)
    }
    
    
    @IBAction func save(_ sender: Any) {
        
        if product == nil {
            product = Product(context: context)
        }
        
        alertText = !validateText(tfProductName.text)
        if !alertText {
            alertText = !validateText(tfProductValue.text)
        }
        alertNumber = !validateNumber(tfProductValue.text)
        
        product?.name = tfProductName.text
        product?.value = NSDecimalNumber(string: tfProductValue.text ?? "0.0")
        //print(stateSelected)
        product?.states = stateSelected
        //print(product?.states?.name)
        product?.isCredit = swProductCard.isOn
        product?.image = ivProductImage.image?.jpegData(compressionQuality: 0.8)
        
        do {
            if alertText || alertNumber {
                showAlert(alertText, alertNumber)
            } else {
                try context.save()
            }
            
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
    }
    
    func showAlert(_ validateText: Bool, _ validateNumber: Bool ) {
        var text: String = ""
        
        if validateText && !validateNumber {
            text = "Todos os campos são obrigatórios, por favor, verifique se estão preenchidos!"
        } else if !validateText && validateNumber {
            text = "O campo de valor aceita apenas números. Por gentileza, verifique novamente!"
        } else if validateText && validateNumber {
            text = "Valores incorretos, por gentileza, verifique se há apenas números no campo de valor e se esqueceu de preencher algum outro campo!"
        }
        
        let alertController = UIAlertController(title: "ComprasUSA", message:
            text, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))

        self.present(alertController, animated: true, completion: nil)
    }
    
    func validateText(_ text: String?) -> Bool {
        guard let message = text else { return false }
            if message == nil || message == "" || message.isEmpty {
                return false
            }
        return true
    }
    
    func validateNumber(_ text: String?) -> Bool {
        guard let number = text else { return false }
        return number.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CompraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            ivProductImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}

//Implementando o protocolo NSFetchedResultsControllerDelegate
extension CompraViewController: NSFetchedResultsControllerDelegate {
    
    //Método que é chamado sempre que uma alteração é feita no contexto
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        loadStates()
        //guard let states = fetchedResultController.fetchedObjects else { return }
        pvProductState.reloadAllComponents()
    }
}

extension CompraViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                
        textField.resignFirstResponder()
        return true
    }
}



