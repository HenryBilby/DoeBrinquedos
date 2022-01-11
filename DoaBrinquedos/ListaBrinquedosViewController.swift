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
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
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
    
    private func loadToyList() {
        listener = firestore.collection(collection).order(by: "name", descending: true).addSnapshotListener(includeMetadataChanges: true, listener: { snapshot, error in
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
        case 2:
            return "Precisa de Reparo"
        default:
            return ""
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
        print("Indice selecionado \(indexPath)")
    }
}
