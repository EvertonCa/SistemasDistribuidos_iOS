//
//  ViewController.swift
//  SistemasDistribuidos_iOS
//
//  Created by Everton Cardoso on 14/05/20.
//  Copyright © 2020 Everton Cardoso. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class ViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var connectedWithLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    
    //MARK: - Variables
    
    var multipeerSession: MultipeerSession!
    var handler:HandlerCPF_CNPJ!
    var messageOrder:[Int] = []
    var timer:Stopwatch!

    //MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        multipeerSession = MultipeerSession(view: self)
        multipeerSession.delegate = self
    }

    //MARK: - Functions
    
    // alert for setting as host or client
    func chooseType() {
        let ac = UIAlertController(title: "Conectar a Servidor", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Entrar na Sessão", style: .default, handler: self.multipeerSession.joinSession))
        ac.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        present(ac, animated: true)
    }
    
    // send the calculated message to host
    func sendToHost() {
        
        // encodes the messages and send them
        let message = Message(peerHashID: self.multipeerSession.myPeerID.hash,
                              messageType: MessageType.Processed.rawValue,
                              messageOrder: self.messageOrder,
                              timeElapsed: self.timer.counter,
                              processedString: self.handler.calculatedStrings)
        
        self.multipeerSession.send(dataToSend: self.multipeerSession.encodeMessage(message: message),
                                   peerToSend: self.multipeerSession.session.connectedPeers.first!)
    }
    
    //MARK: - IBActions
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        self.chooseType()
    }
}

//MARK: - Multipeer Session Delegate

extension ViewController: MultipeerSessionDelegate {
    func connectedDevicesChanged(manager: MultipeerSession, connectedDevices: [String]) {
        var connected_peers = "Conectado com:\n"
        for peer in connectedDevices {
            connected_peers += peer + "\n"
        }
        DispatchQueue.main.async {
            self.connectedWithLabel.isHidden = false
            self.connectedWithLabel.text = connected_peers
            self.statusLabel.isHidden = false
            self.statusLabel.text = "Aguardando lista de CPFs e CNPJs..."
            self.startButton.isHidden = true
        }
    }
    
    func messageReceived(manager: MultipeerSession, message: Message, from: MCPeerID) {
        if message.messageType == MessageType.ToProcess.rawValue {
            DispatchQueue.main.async {
                self.statusLabel.isHidden = false
                self.statusLabel.text = "CPFs e CNPJs recebidos. Aguardando host..."
                self.multipeerSession.send(dataToSend: self.multipeerSession.encodeMessage(message: Message(peerHashID: self.multipeerSession.myPeerID.hash, messageType: MessageType.Received.rawValue, messageOrder: [])), peerToSend: from)
            }
            self.messageOrder = message.messageOrder
            self.handler = HandlerCPF_CNPJ(stringList: message.stringList!, view: self)
            
        }
        else if message.messageType == MessageType.Received.rawValue {
            DispatchQueue.main.async {
                self.statusLabel.text = "Enviado com Sucesso!"
            }
        }
        else if message.messageType == MessageType.Go.rawValue {
            DispatchQueue.main.async {
                self.statusLabel.isHidden = false
                self.statusLabel.text = "Calculando..."
                self.timer = Stopwatch(view: self)
                self.timer.startTimer()
            }
            DispatchQueue.global(qos: .default).async {
                self.handler.calculate()
                DispatchQueue.main.async {
                    self.timer.stopTimer()
                    self.statusLabel.text = "Enviando..."
                }
                self.sendToHost()
            }
        }
    }
}

