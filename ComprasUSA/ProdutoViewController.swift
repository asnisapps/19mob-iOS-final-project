//
//  ProdutoViewController.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit

class ProdutoViewController: UIViewController {

    @IBOutlet weak var tfProductName: UITextField!
    @IBOutlet weak var pvProductState: UIPickerView!
    @IBOutlet weak var tfProductValue: UITextField!
    @IBOutlet weak var swProductCard: UISwitch!
    @IBOutlet weak var ivProductImage: UIImageView!
    @IBOutlet weak var btProductSave: UIButton!
    
    var product: Product?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let product = product {
            tfProductName.text = product.name
            tfProductValue.text = "\(product.value ?? 0)"
            swProductCard.isOn = product.isCredit
            pvProductState.dataSource = product.states as? UIPickerViewDataSource
            //pvProductState.selectedRow(inComponent: product.states.)
            ivProductImage.image = product.image as? UIImage
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
        
        product?.name = tfProductName.text
        product?.value = NSDecimalNumber(string: tfProductValue.text ?? "0.0")
        //product?.states =
        product?.isCredit = swProductCard.isOn
        product?.image = ivProductImage.image?.jpegData(compressionQuality: 0.8)
        
        do {
            try context.save()
        } catch {
            print(error.localizedDescription)
        }
        navigationController?.popViewController(animated: true)
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

extension ProdutoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            ivProductImage.image = image
        }
        dismiss(animated: true, completion: nil)
    }
}
