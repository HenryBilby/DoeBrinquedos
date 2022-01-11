//
//  ViewController.swift
//  DoaBrinquedos
//
//  Created by Henry Bilby on 10/01/22.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var textFieldName: UITextField!
    
    @IBOutlet weak var textFieldEmail: UITextField!
    
    @IBOutlet weak var textFieldPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    @IBAction func actionEntrar(_ sender: Any) {
        if isValidSignIn(){
            Auth.auth().signIn(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { authResult, _ in
                guard let user = authResult?.user else {
                    self.showDialog(with: "Erro ao realizar o login")
                    return
                }
//                self.showDialog(with: "Sucesso ao realizar o login")
                self.updateUserAndProceed(user: user)
            }
        }
    }
    
    @IBAction func actionCadastrar(_ sender: Any) {
        if isValidSignUp() {
            Auth.auth().createUser(withEmail: textFieldEmail.text!, password: textFieldPassword.text!) { authResult, error in
                if let error = error {
                    var message = "Erro ao criar usuário"
                    let authErrorCode = AuthErrorCode(rawValue: error._code)
                    
                    switch authErrorCode {
                    case .emailAlreadyInUse:
                        message = "Email já cadastrado"
                    case .weakPassword:
                        message = "Senha fraca"
                    default:
                        break
                    }
                    
                    self.showDialog(with: message)
                } else {
                    if let user = authResult?.user {
                        self.updateUserAndProceed(user: user)
                    }
                    let message = "Sucesso ao criar usuário"
                    self.showDialog(with: message)
                }
            }
        }
    }
    
    private func updateUserAndProceed(user: User){
        if let text = textFieldName.text, text.isEmpty {
            gotoMainScreen()
        } else {
            let request = user.createProfileChangeRequest()
            request.displayName = textFieldName.text
            request.commitChanges { _ in
                self.gotoMainScreen()
            }
        }
        
    }
    
    private func gotoMainScreen() {
        guard let listaBrinquedosController = storyboard?.instantiateViewController(withIdentifier: "ListaBrinquedosViewController") else {return}
        show(listaBrinquedosController, sender: nil)
    }
    
    private func isValidSignUp() -> Bool {
        if isValid(textField: textFieldName),
           isValid(textField: textFieldEmail),
           isValid(textField: textFieldPassword){
            return true
        }
        return false
    }
    
    private func isValidSignIn() -> Bool {
        if isValid(textField: textFieldEmail),
           isValid(textField: textFieldPassword){
            return true
        }
        return false
    }
    
    private func isValid(textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            removeError(textField: textField)
            return true
        } else {
            showError(textField: textField)
            return false
        }
    }
    
    private func showError(textField: UITextField){
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1
        let message = "Corrigir o campo marcado de vermelho"
        showDialog(with: message)
    }
    
    private func removeError(textField: UITextField){
        if textField.layer.borderColor == UIColor.red.cgColor {
            textField.layer.borderColor = UIColor.clear.cgColor
            textField.layer.borderWidth = 0
        }
    }
    
    private func showDialog(with message: String){
        let alert = UIAlertController(title: "Doar Brinquedos APP", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(alertAction)
        
        present(alert, animated: true, completion: nil)
    }
    
}

