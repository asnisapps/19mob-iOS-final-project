//
//  TotalViewController.swift
//  ComprasUSA
//
//  Created by Fabio Asnis Campos da Silva on 06/06/20.
//  Copyright © 2020 FIAP. All rights reserved.
//

import UIKit
import CoreData

class TotalViewController: UIViewController {
    
    @IBOutlet weak var lbTotalUSD: UILabel!
    @IBOutlet weak var lbTotalBRL: UILabel!
    
    var totalUSD: Decimal = 0.0
    var totalBRL: Decimal = 0.0
    
    var exchangeRate: Decimal = 4.0
    var percIOF:Decimal = 6.38
    
    var fetchedResultController: NSFetchedResultsController<Product>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Inicia valores com 0
        lbTotalUSD.text = "0.0"
        lbTotalBRL.text = "0.0"
        
        //Carrega produtos
        loadProducts()
    }
    
    func loadProducts() {
        
        let fetchRequest: NSFetchRequest<Product> = Product.fetchRequest()
        
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [ sortDescriptor ]
        
        fetchedResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultController.delegate = self
        do {
            try fetchedResultController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func calculateTotals() {
        
        //Verifica se existem produtos, caso contrario exibe 0 para os totais
        if let count = fetchedResultController.fetchedObjects?.count{
            
            //Caso existam produtos
            if count > 0 {
                
                //Salva produtos numa variavel
                let products = fetchedResultController.fetchedObjects!
                                
                //Varre todos os produtos existentes
                for product in products {
                    
                    //Busca o valor bruto do produto
                    let decimalValueOfProduct = product.value?.decimalValue
                    
                    //Soma o valor bruto em dolar ao total USD
                    totalUSD = totalUSD + decimalValueOfProduct!
                    
                    //Busca a taxa do estado do produto
                    let taxFromState = product.states?.tax?.decimalValue
                                        
                    //Calcula o total em BRL
                    //totalProductBRL = ValorProduto * ((TaxaEstado/100) + 1) * CotacaoDolar
                    var totalProductBRL = decimalValueOfProduct! * ( (taxFromState!/100) + 1 ) * exchangeRate
 
                    //Verifica se produto foi pago com cartão
                    if product.isCredit {
                        //Usou cartão de credito, incluir IOF
                        totalProductBRL = totalProductBRL * ( (percIOF/100) + 1 )
                    }
                    
                    //Soma o valor calculado em BRL do produto ao total BRL
                    totalBRL = totalBRL + totalProductBRL
                }
                
            }
            
        } else {
            //Não existem produtos
            totalUSD = 0.0
            totalBRL = 0.0
        }
        
        //Exibe totais na tela
        lbTotalUSD.text = "0.0"
        lbTotalBRL.text = "0.0"
    }

}

extension TotalViewController: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        //Recalcula total com alteração
        calculateTotals()
    }
    
}
