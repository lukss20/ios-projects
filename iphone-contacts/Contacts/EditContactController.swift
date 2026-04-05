//
//  EditContactController.swift
//  luchit22Contacts
//
//  Created by lukss on 22.12.25.
//

import UIKit

class EditContactController: UIViewController {

    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var initialLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    var contact: Contact?
    var onSave: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        initialLabel.text = String(contact!.name.prefix(1)).uppercased()
        initialLabel.layer.cornerRadius = initialLabel.frame.height / 2
        initialLabel.clipsToBounds = true
        nameLabel.text = contact?.name
        phoneTextField.text = contact?.phone
    }

    @IBAction func saveTapped(_ sender: UIButton) {
        guard let newPhone = phoneTextField.text, !newPhone.isEmpty else { return }
        onSave?(newPhone)
        navigationController?.popViewController(animated: true)
    }
}

