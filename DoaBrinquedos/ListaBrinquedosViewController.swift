//
//  ListaBrinquedosViewController.swift
//  DoaBrinquedos
//
//  Created by Henry Bilby on 10/01/22.
//

import UIKit
import Firebase

class ListaBrinquedosViewController: UIViewController {
    
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var tableViewBrinquedos: UITableView!
    
    let collection = "toy"
    
    var toys : [Toy] = []
    
    lazy var firestore : Firestore = {
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = true //persiste as informaçoes locais na ausencia de internet, depois sincroniza com a cloud
        
        let firestore = Firestore.firestore()
        firestore.settings = settings
        
        return firestore
    }()
    
    var listener: ListenerRegistration!
    
    var name: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        loadToyList()
        tableViewBrinquedos.dataSource = self
        tableViewBrinquedos.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CadastraEditaViewController,
           let toy = sender as? Toy {
            controller.toy = toy
        }
    }
    
    @IBAction func addAction(_ sender: Any) {
//        showAlertForToy()
        performSegue(withIdentifier: "gotoEdit", sender: nil)
    }
    
    private func loadToyList() {
        listener = firestore.collection(collection).order(by: "name", descending: false).addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
            if let error = error {
                print(error)
            } else {
                guard let snapshot = snapshot else {return}
                print("snapshot total mudancas : \(snapshot.documentChanges.count)")
                
                if snapshot.metadata.isFromCache || snapshot.documentChanges.count > 0 {
                    self.showToysFrom(snapshot)
                }
            }
        })
    }
    
    private func showToysFrom(_ snapshot: QuerySnapshot){
        toys.removeAll()
        for document in snapshot.documents {
            let keyValue = document.data()
            
            if let name = keyValue["name"] as? String,
               let state = keyValue["state"] as? Int,
               let donor = keyValue["donor"] as? String,
               let address = keyValue["address"] as? String,
               let phone = keyValue["phone"] as? String {
                let toy = Toy(id: document.documentID, name: name, state: state, donor: donor, address: address, phone: phone)
                toys.append(toy)
            }
            
        }
        tableViewBrinquedos.reloadData()
    }
    
    private func showAlertForToy(_ toy: Toy? = nil){
        let alert = UIAlertController(title: "Brinquedo", message: "Informe as informações do brinquedo", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Nome"
            textField.text = toy?.name
        }
        
        alert.addTextField { textField in
            textField.keyboardType = .numberPad
            textField.placeholder = "Estado: 0-Novo, 1-Usado, 2-Precisa de Reparo"
            textField.text = toy?.state.description
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Doador:"
            textField.text = toy?.donor
        }
        
        alert.addTextField { textField in
            textField.placeholder = "Endereço:"
            textField.text = toy?.address
        }
        
        alert.addTextField { textField in
            textField.keyboardType = .phonePad
            textField.placeholder = "Telefone: "
            textField.text = toy?.phone
        }
        
        let save = UIAlertAction(title: "Salvar", style: .default){ _ in
            guard let name = alert.textFields?[0].text else {return}
            
            guard let stateString = alert.textFields?[1].text,
                  let state = Int(stateString) else {return}
            
            guard let donor = alert.textFields?[2].text else {return}
            
            guard let address = alert.textFields?[3].text else {return}
            
            guard let phone = alert.textFields?[4].text else {return}
            
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
        }
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler: nil))
        alert.addAction(save)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    private func setLabelUserName(){
        if let name = name {
            print(name)
            labelUserName.text = "Bem vindo \(name),"
        }
    }
    
    private func getStateName(state: Int) -> String {
        switch state {
        case 0:
            return "Novo"
        case 1:
            return "Usado"
        default:
            return "Precisa de Reparo"
        }
    }
}

extension ListaBrinquedosViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        toys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "cell") {
            
            let toy = toys[indexPath.row]
            cell.textLabel?.text = toy.name
            cell.detailTextLabel?.text = getStateName(state: toy.state)
            
            return cell
        }
        return UITableViewCell()
    }
}

extension ListaBrinquedosViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        showAlertForToy(toys[indexPath.row])
        performSegue(withIdentifier: "gotoEdit", sender: toys[indexPath.row])
    }
}
