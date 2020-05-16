//
//  HandleCPF_CNPJ.swift
//  SistemasDistribuidos_iOS
//
//  Created by Everton Cardoso on 14/05/20.
//  Copyright © 2020 Everton Cardoso. All rights reserved.
//
import Foundation

class HandlerCPF_CNPJ {
    
    var stringList:[String]
    var calculatedStrings:String = String()
    
    var viewController:ViewController
    
    init(stringList:[String], view:ViewController) {
        self.stringList = stringList
        //self.stringList.removeLast()
        self.viewController = view
    }
    
    // calculates the entire list
    func calculate() {
        
        DispatchQueue.main.async {
            self.viewController.progressBar.isHidden = false
            self.viewController.progressBar.progress = 0
        }
        // iterates for each number
        for (index, valor) in self.stringList.enumerated() {
            // trims the number, removing whitespaces
            let trimmedValor = valor.trimmingCharacters(in: .whitespaces)
            // if number is CPF
            if trimmedValor.count == 9 {
                self.calculatedStrings += self.calculateCPF(cpf: trimmedValor) + "\n"
            } else {
                self.calculatedStrings += self.calculateCNPJ(cnpj: trimmedValor) + "\n"
            }
            DispatchQueue.main.async {
                self.viewController.progressBar.progress = Float(index) / Float(self.stringList.count)
            }
        }
    }
    
    // calculate the verification digit for CPF
    func calculateCPF(cpf:String) -> String {
        var digits = cpf.compactMap{ $0.wholeNumberValue }
        
        var sumDigits = 0
        for (index, number) in digits.enumerated(){
            sumDigits += (number * (10 - index))
        }
        let rest = sumDigits % 11
        var dig10 = 0
        
        if rest != 0 && rest != 1 {
            dig10 = 11 - rest
        }
        
        digits.append(dig10)
        sumDigits = 0
        for (index, number) in digits.enumerated(){
            sumDigits += (number * (11 - index))
        }
        let rest2 = sumDigits % 11
        var dig11 = 0
        
        if rest2 != 0 && rest2 != 1 {
            dig11 = 11 - rest2
        }
        digits.append(dig11)
        
        var calculatedCPF = String()
        
        for index in 0...2 {
            calculatedCPF.append(String(digits[index]))
        }
        calculatedCPF.append(".")
        for index in 3...5 {
            calculatedCPF.append(String(digits[index]))
        }
        calculatedCPF.append(".")
        for index in 6...8 {
            calculatedCPF.append(String(digits[index]))
        }
        calculatedCPF.append("-")
        for index in 9...10 {
            calculatedCPF.append(String(digits[index]))
        }
        
        return calculatedCPF
    }
    
    // calculate the verification digit for CNPJ
    func calculateCNPJ(cnpj:String) -> String {
        var digits = cnpj.compactMap{ $0.wholeNumberValue }
        
        var sumDigits = 0
        for index in 0...3 {
            sumDigits += (digits[index] * (5 - index))
        }
        for index in 4...11 {
            sumDigits += (digits[index] * (13 - index))
        }
        
        let rest = sumDigits % 11
        var dig13 = 0
        
        if rest != 0 && rest != 1 {
            dig13 = 11 - rest
        }
        
        digits.append(dig13)
        sumDigits = 0
        for index in 0...4 {
            sumDigits += (digits[index] * (6 - index))
        }
        for index in 5...12 {
            sumDigits += (digits[index] * (14 - index))
        }
        let rest2 = sumDigits % 11
        var dig14 = 0
        
        if rest2 != 0 && rest2 != 1 {
            dig14 = 11 - rest2
        }
        digits.append(dig14)
        
        var calculatedCNPF = String()
        
        for index in 0...1 {
            calculatedCNPF.append(String(digits[index]))
        }
        calculatedCNPF.append(".")
        for index in 2...4 {
            calculatedCNPF.append(String(digits[index]))
        }
        calculatedCNPF.append(".")
        for index in 5...7 {
            calculatedCNPF.append(String(digits[index]))
        }
        calculatedCNPF.append("/")
        for index in 8...11 {
            calculatedCNPF.append(String(digits[index]))
        }
        calculatedCNPF.append("-")
        for index in 12...13 {
            calculatedCNPF.append(String(digits[index]))
        }
        
        return calculatedCNPF
    }
    
}

