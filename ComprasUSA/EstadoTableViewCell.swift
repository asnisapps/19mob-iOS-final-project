//
//  EstadoTableViewCell.swift
//  ComprasUSA
//
//  Created by Filipe Walter Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit



class EstadoTableViewCell: UITableViewCell{


    
    @IBOutlet weak var lbState: UILabel!
    
    @IBOutlet weak var lbTax: UILabel!
    func prepare (with estado: State){
        
        lbState.text = estado.name
        lbTax.text = estado.tax
        
      
      
        
       
        
        
        
    }
    
    
    

  
}


