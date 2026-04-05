//
//  NumberViewController.swift
//  luchit22phone
//
//  Created by lukss on 20.11.25.
//


import UIKit

class NumberViewController: UIViewController {
    
    @IBOutlet weak var numberLabel: UILabel!
    
    private var typedNumber: String = "" {
        didSet {
            numberLabel.text = formatNumber(typedNumber)
        }
    }
    
    private func formatNumber(_ number: String) -> String {
        let digits = number.replacingOccurrences(of: "-", with: "")
        
        var result = ""
        for (index, digit) in digits.enumerated() {
            if index != 0 && index % 3 == 0 {
                result.append("-")
            }
            result.append(digit)
        }
        return result
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        typedNumber = ""
    }
    
    
    @IBAction func numberPressed(_ sender: UIButton) {
        if let digit = sender.titleLabel?.text?.components(separatedBy: "\n").first {
            typedNumber.append(digit)
        }
    }
    
    
    @IBAction func deletePressed(_ sender: UIButton) {
        if !typedNumber.isEmpty {
            typedNumber.removeLast()
        }
    }
    
    @IBAction func callPressed(_ sender: UIButton) {
        performSegue(withIdentifier: "goToCallScreen", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCallScreen" {
            let vc = segue.destination as! CallingViewController
            vc.phoneNumber = typedNumber
        }
    }
}
