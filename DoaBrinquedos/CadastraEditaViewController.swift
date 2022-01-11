//
//  CadastraEditaViewController.swift
//  DoaBrinquedos
//
//  Created by Henry Bilby on 11/01/22.
//

import UIKit
import Firebase

class CadastraEditaViewController: UIViewController {
    
    var toy: Toy?
    let collection = "toy"

    @IBOutlet weak var textFieldName: UITextField!
    @IBOutlet weak var segmentedControlState: UISegmentedControl!
    @IBOutlet weak var textFieldDonor: UITextField!
    @IBOutlet weak var textFieldAddress: UITextField!
    @IBOutlet weak var textFieldPhone: UITextField!
    
    lazy var firestore : Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true //persiste as informaçoes locais na ausencia de internet, depois sincroniza com a cloud
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        
        return firestore
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let toy = toy {
            self.title = "Editar Brinquedo"
            setTextFields(toy: toy)
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let name = textFieldName.text else {return}
        
        guard let donor = textFieldDonor.text else {return}
        
        guard let address = textFieldAddress.text else {return}
        
        guard let phone = textFieldPhone.text else {return}
        
        let state = segmentedControlState.selectedSegmentIndex
        
        let data : [String: Any] = [
            "name": name,
            "state": state,
            "donor": donor,
            "address": address,
            "phone": phone
        ]
        
        if let toy = toy {
            //edicao
            self.firestore.collection(self.collection).document(toy.id).updateData(data)
        } else {
            //criacao
            self.firestore.collection(self.collection).addDocument(data: data)
        }
        
        showDialog(with: "Brinquedo \(name) salvo com sucesso!!!")
        
    }
    
    private func showDialog(with message: String){
        let alert = UIAlertController(title: "Doe Brinquedos APP", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    private func setTextFields(toy: Toy) {
        textFieldName.text = toy.name
        textFieldDonor.text = toy.donor
        textFieldPhone.text = toy.phone
        textFieldAddress.text = toy.address
        segmentedControlState.selectedSegmentIndex = toy.state
    }
}
