//
//  OutgoingCallViewController.swift
//  luchit22phone
//
//  Created by lukss on 20.11.25.
//


import UIKit

class CallingViewController: UIViewController {
    
    var phoneNumber: String = ""
    
    @IBOutlet weak var callNumberLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callNumberLabel.text = formatNumber(phoneNumber)
        view.alpha = 0
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.3) {
            self.view.alpha = 1
        }
    }
    
    @IBAction func endCallPressed(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
}

