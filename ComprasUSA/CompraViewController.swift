//
//  ProdutoViewController.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit

class CompraViewController: UIViewController {

    @IBOutlet weak var tfProductName: UITextField!
    @IBOutlet weak var pvProductState: UIPickerView!
    @IBOutlet weak var tfProductValue: UITextField!
    @IBOutlet weak var swProductCard: UISwitch!
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var btProductSave: UIButton!
    
    var product: Product?
    var alertText: Bool = false
    var alertNumber: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let product = product {
            tfProductName.text = product.name
            tfProductValue.text = "\(product.value ?? 0)"
            swProductCard.isOn = product.isCredit
            pvProductState.dataSource = product.states as? UIPickerViewDataSource
            //pvProductState.selectedRow(inComponent: product.states.)
            if let data = product.image {
                ivProductImage.image = UIImage(data: data)
            }
            btProductSave.setTitle("Alterar", for: .normal)
        }
        
        // Do any additional setup after loading the view.
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            ivProductImage.isUserInteractionEnabled = true
        ivProductImage.addGestureRecognizer(tapGestureRecognizer)
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
        //product?.states =
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
