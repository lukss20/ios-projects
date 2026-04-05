//
//  NoteDetailViewController.swift
//  luchit22Notes
//
//  Created by lukss on 13.01.26.
//


import UIKit
import CoreData

protocol NoteDetailDelegate: AnyObject {
    func didSaveNote()
}

class NoteDetailViewController: UIViewController {
    @IBOutlet weak var notetitle: UITextField!
    @IBOutlet weak var notetext: UITextView!

    var note: Note?
    weak var delegate: NoteDetailDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        notetitle.font = UIFont.boldSystemFont(ofSize: 20)
        notetitle.placeholder = "Enter title..."
        notetitle.textColor = .label

        notetext.font = UIFont.systemFont(ofSize: 16)
        notetext.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        notetext.layer.cornerRadius = 10
        notetext.backgroundColor = UIColor.systemGray6
        if let note = note {
            notetitle.text = note.title
            notetext.text = note.text
        } else {
            notetitle.text = ""
            notetext.text = ""
        }
    }

    @IBAction func saveTapped(_ sender: UIBarButtonItem) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        if note == nil {
            note = Note(context: context)
        }

        note?.title = notetitle.text
        note?.text = notetext.text
        try! context.save()
        delegate?.didSaveNote()
        navigationController?.popViewController(animated: true)
        
    }
}
