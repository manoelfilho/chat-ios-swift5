//
//  ChatViewController.swift
//  Flash Chat iOS13
//
//  Created by Angela Yu on 21/10/2019.
//  Copyright © 2019 Angela Yu. All rights reserved.
//

import UIKit
import Firebase

class ChatViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextfield: UITextField!
    
    let db = Firestore.firestore()
    
    var messages: [Message] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.hidesBackButton = true
        title = K.appName
        
        tableView.dataSource = self
        tableView.register(
            UINib(nibName: K.cellNibName, bundle: nil),
            forCellReuseIdentifier: K.cellIdentifier
        )
        
        loadMessages()
    }
    
    func loadMessages() {
        
        /*
         Listener para o firestore. Esse método (addSnapshotListener)é capaz de escutar
         modificacoes na colecao e daó tomar uma ação
         */
        
        db.collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField)
            .addSnapshotListener { (querySnapshot, error) in
                
            self.messages = []
                
            if let e = error {
                print("There was a issue retrieving datas from Firestore. \(e.localizedDescription)")
            }else{
                if let snapshotDocuments = querySnapshot?.documents{
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
                            let newMessage = Message(sender: messageSender, body: messageBody)
                            
                            self.messages.append(newMessage)
                            
                            //Chamar este método sempre que realizamos uma modificacao na view do app
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                let indexPath = IndexPath(row: self.messages.count-1, section: 0)
                                
                                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
                            }
                        }
                    }
                }
            }
        }
        
        //        Forma de fazer uma busca pelos dados do Firestore a partir de uma chamada de método:
        //        db.collection(K.FStore.collectionName).getDocuments { (querySnapshot, error) in
        //            if let e = error {
        //                print("There was a issue retrieving datas from Firestore. \(e.localizedDescription)")
        //            }else{
        //                if let snapshotDocuments = querySnapshot?.documents{
        //                    for doc in snapshotDocuments {
        //                        let data = doc.data()
        //                        if let messageSender = data[K.FStore.senderField] as? String, let messageBody = data[K.FStore.bodyField] as? String {
        //                            let newMessage = Message(sender: messageSender, body: messageBody)
        //                            self.messages.append(newMessage)
        //
        //                            //Chamar este método sempre que realizamos uma modificacao na view do app
        //                            DispatchQueue.main.async {
        //                                self.tableView.reloadData()
        //                            }
        //                        }
        //                    }
        //                }
        //            }
        //        }
    }
    
    @IBAction func logoutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutErro as NSError {
            print("Erro ao deslogar: %@", signOutErro)
        }
    }
    
    @IBAction func sendPressed(_ sender: UIButton) {
        
        //POSSSO VALIdar a existencia das duas variaveis ao mesmo tempo e daí executar qualquer outra coisa:
        if let messageBody = messageTextfield.text, let messageSender = Auth.auth().currentUser?.email {
            
            db.collection(K.FStore.collectionName).addDocument(data: [
                
                K.FStore.senderField: messageSender,
                K.FStore.bodyField: messageBody,
                K.FStore.dateField: Date().timeIntervalSince1970
                
            ]) { (error) in
                
                if let e = error {
                    print("There was a issue  saving data to firestore, \(e.localizedDescription)")
                }else{
                    DispatchQueue.main.async {
                        self.messageTextfield.text = ""
                    }
                }
                
            }
        }
        
    }
    
}

//MARK: - UITableVieDataSource
extension ChatViewController:UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath) as! MessageCell
        print(message.sender)
        
        //se a msg é do usuário logado
        if message.sender == Auth.auth().currentUser?.email{
            
            DispatchQueue.main.async {
                cell.rightImageView.isHidden = false
                cell.leftImage.isHidden = true
                cell.messageBubble.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            }
            
        }else{
            
            DispatchQueue.main.async {
                cell.rightImageView.isHidden = true
                cell.leftImage.isHidden = false
                cell.messageBubble.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
            }
            
        }
        
        cell.label.text = message.body
        return cell
    }
    
}
