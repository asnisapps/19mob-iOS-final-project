//
//  CompraTableViewCell.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 07/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit

class CompraTableViewCell: UITableViewCell {

    @IBOutlet weak var lbProductName: UILabel!
    @IBOutlet weak var lbProductValue: UILabel!
    @IBOutlet weak var ivProductImage: UIImageView!
    
    func prepare(with product: Product) {
        lbProductName.text = product.name
        lbProductValue.text = "\(product.value ?? 0.00)"
        
        //Se houver imagem cadastrada, recuperamos e geramos a UIImage baseado no dado
        if let data = product.image {
            ivProductImage.image = UIImage(data: data)
        }
    }

}
