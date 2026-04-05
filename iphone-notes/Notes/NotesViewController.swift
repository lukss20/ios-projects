//
//  ViewController.swift
//  luchit22Notes
//
//  Created by lukss on 13.01.26.
//


import UIKit
import CoreData

class NotesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, PinterestLayoutDelegate, NoteDetailDelegate {

    @IBOutlet weak var collectionView: UICollectionView!
    var notes: [Note] = []

    var context: NSManagedObjectContext {
        (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Notes"
        
        let layout = PinterestLayout()
        layout.delegate = self
        collectionView.collectionViewLayout = layout
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPress)
        
        fetchNotes()
    }

    func fetchNotes() {
        do {
            notes = try context.fetch(Note.fetchRequest())
            collectionView.reloadData()
        } catch {
            print("Fetch failed: \(error)")
        }
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return notes.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "NoteCell", for: indexPath) as! NoteCell
        let note = notes[indexPath.item]
        cell.title.text = note.title
        cell.text.text = note.text
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        openDetailVC(with: notes[indexPath.item])
    }

    @IBAction func addNoteTapped(_ sender: UIBarButtonItem) {
        openDetailVC(with: nil)
    }

    private func openDetailVC(with note: Note?) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC = storyboard.instantiateViewController(withIdentifier: "NoteDetailViewController") as! NoteDetailViewController
        detailVC.note = note
        detailVC.delegate = self
        navigationController?.pushViewController(detailVC, animated: true)
    }

    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        
        let point = gesture.location(in: collectionView)
        
        guard let indexPath = collectionView.indexPathForItem(at: point) else { return }

        let noteToDelete = notes[indexPath.item]

        let alert = UIAlertController(title: "Delete Note?", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive) { _ in
            self.context.delete(noteToDelete)
            try? self.context.save()
            self.fetchNotes()
        })
        present(alert, animated: true)
    }

    func didSaveNote() {
        fetchNotes()
    }

    func collectionView(_ collectionView: UICollectionView, heightForTextAtIndexPath indexPath: IndexPath, width: CGFloat) -> CGFloat {
        let note = notes[indexPath.item]
        let titleHeight = heightForLabel(text: note.title ?? "", width: width, font: .boldSystemFont(ofSize: 17))
        let textHeight = heightForLabel(text: note.text ?? "", width: width, font: .systemFont(ofSize: 15))
        return titleHeight + textHeight
    }

    func heightForLabel(text: String, width: CGFloat, font: UIFont) -> CGFloat {
        let rect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let box = text.boundingRect(with: rect,
                                    options: [.usesLineFragmentOrigin, .usesFontLeading],
                                    attributes: [.font: font],
                                    context: nil)
        return ceil(box.height)
    }
}
