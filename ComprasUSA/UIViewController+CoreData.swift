//
//  UIViewController+CoreData.swift
//  ComprasUSA
//
//  Created by Guilherme Victor Feitosa da Cunha on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController{
    
    //Variável para apontar ao AppDelegate
    var appDelegate: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    //Variável que dá acesso ao Managed Object Context, que pode ser acessado
    //através da propriedade viewContext da persistentContainer
    var context: NSManagedObjectContext {
        return appDelegate.persistentContainer.viewContext
        
    }
}
