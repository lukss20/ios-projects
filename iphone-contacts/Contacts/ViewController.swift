//
//  ViewController.swift
//  luchit22Contacts
//
//  Created by lukss on 22.12.25.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var myContacts: [ContactSection] = []
    var isGridMode = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStuff()
        loadMyContacts()
    }
    
    private func loadMyContacts() {
        let guy1 = Contact(name: "Luka chitaia", phone: "551211701")
        let guy2 = Contact(name: "Lika chitaia", phone: "551211702")
        let firstGroup = ContactSection(letter: "L", contacts: [guy1, guy2], isCollapsed: false)
        myContacts = [firstGroup]
    }
    
    private func setupStuff() {
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.collectionViewLayout = makeGridLayout()
        
        collectionView.register(GridContactCell.self, forCellWithReuseIdentifier: GridContactCell.id)
        collectionView.register(ContactHeaderView.self,
                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                withReuseIdentifier: ContactHeaderView.id)
        
        let holdGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleHold(_:)))
        collectionView.addGestureRecognizer(holdGesture)
        
        updateViews()
    }

    private func updateViews() {
        tableView.isHidden = isGridMode
        collectionView.isHidden = !isGridMode
    }

    private func makeGridLayout() -> UICollectionViewLayout {
        let boxSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.33),
                                              heightDimension: .absolute(100))
        let box = NSCollectionLayoutItem(layoutSize: boxSize)
        box.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

        let rowDimensions = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .estimated(100))
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: rowDimensions, subitems: [box])

        let part = NSCollectionLayoutSection(group: horizontalGroup)
        part.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)

        let topSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let topPart = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: topSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        part.boundarySupplementaryItems = [topPart]

        return UICollectionViewCompositionalLayout(section: part)
    }

    func toggleGroup(at idx: Int) {
        myContacts[idx].isCollapsed.toggle()
        tableView.reloadSections(IndexSet(integer: idx), with: .automatic)
        collectionView.reloadSections(IndexSet(integer: idx))
    }

    func addNewPerson(name: String, phone: String) {
        let newGuy = Contact(name: name, phone: phone)
        let char = String(name.prefix(1)).uppercased()

        if let pos = myContacts.firstIndex(where: { $0.letter == char }) {
            myContacts[pos].contacts.append(newGuy)
        } else {
            let freshGroup = ContactSection(letter: char, contacts: [newGuy], isCollapsed: false)
            myContacts.append(freshGroup)
            myContacts.sort { $0.letter < $1.letter }
        }
        refreshAll()
    }

    func removePerson(at spot: IndexPath) {
        myContacts[spot.section].contacts.remove(at: spot.row)
        if myContacts[spot.section].contacts.isEmpty {
            myContacts.remove(at: spot.section)
        }
        refreshAll()
    }

    private func refreshAll() {
        tableView.reloadData()
        collectionView.reloadData()
    }

    func goToEdit(section: Int, row: Int) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        guard let editor = sb.instantiateViewController(withIdentifier: "EditContactVC") as? EditContactController else { return }

        let person = myContacts[section].contacts[row]
        editor.contact = person
        editor.onSave = { [weak self] newNum in
            self?.myContacts[section].contacts[row].phone = newNum
            self?.tableView.reloadRows(at: [IndexPath(row: row, section: section)], with: .automatic)
            self?.collectionView.reloadItems(at: [IndexPath(item: row, section: section)])
        }

        navigationController?.pushViewController(editor, animated: true)
    }

    @IBAction func switchLayoutTapped(_ sender: UIBarButtonItem) {
        isGridMode.toggle()
        updateViews()
        sender.image = UIImage(systemName: isGridMode ? "list.bullet" : "square.grid.3x3")
    }

    @IBAction func addContactTapped(_ sender: UIBarButtonItem) {
        let popup = UIAlertController(title: "New Contact", message: nil, preferredStyle: .alert)
        popup.addTextField { $0.placeholder = "Name" }
        popup.addTextField { $0.placeholder = "Phone" }

        let addBtn = UIAlertAction(title: "Add", style: .default) { [weak self] _ in
            guard let theName = popup.textFields?[0].text, !theName.isEmpty,
                  let thePhone = popup.textFields?[1].text, !thePhone.isEmpty else { return }
            self?.addNewPerson(name: theName, phone: thePhone)
        }

        popup.addAction(addBtn)
        popup.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(popup, animated: true)
    }

    @objc func handleHold(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        let pos = gesture.location(in: collectionView)

        if let path = collectionView.indexPathForItem(at: pos) {
            let confirm = UIAlertController(title: nil, message: "Delete this contact?", preferredStyle: .actionSheet)
            confirm.addAction(UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                self?.removePerson(at: path)
            })
            confirm.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(confirm, animated: true)
        }
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { myContacts.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        myContacts[section].isCollapsed ? 0 : myContacts[section].contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let theCell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        let guy = myContacts[indexPath.section].contacts[indexPath.row]
        theCell.textLabel?.text = guy.name
        theCell.detailTextLabel?.text = guy.phone
        return theCell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goToEdit(section: indexPath.section, row: indexPath.row)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let box = UIView()
        box.backgroundColor = .systemGray6

        let txt = UILabel()
        txt.text = myContacts[section].letter
        txt.font = .boldSystemFont(ofSize: 18)
        txt.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(txt)

        NSLayoutConstraint.activate([
            txt.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            txt.centerYAnchor.constraint(equalTo: box.centerYAnchor)
        ])

        let clickGesture = UITapGestureRecognizer(target: self, action: #selector(headerClicked(_:)))
        box.tag = section
        box.addGestureRecognizer(clickGesture)
        return box
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 40 }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let removeBtn = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, done in
            self?.removePerson(at: indexPath)
            done(true)
        }
        return UISwipeActionsConfiguration(actions: [removeBtn])
    }

    @objc private func headerClicked(_ gesture: UITapGestureRecognizer) {
        guard let num = gesture.view?.tag else { return }
        toggleGroup(at: num)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int { myContacts.count }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        myContacts[section].isCollapsed ? 0 : myContacts[section].contacts.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let gridBox = collectionView.dequeueReusableCell(withReuseIdentifier: GridContactCell.id, for: indexPath) as! GridContactCell
        let guy = myContacts[indexPath.section].contacts[indexPath.row]
        gridBox.configure(with: guy)
        return gridBox
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        goToEdit(section: indexPath.section, row: indexPath.row)
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
                                                                 at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else { return UICollectionReusableView() }

        let top = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                     withReuseIdentifier: ContactHeaderView.id,
                                                                     for: indexPath) as! ContactHeaderView
        top.configure(text: myContacts[indexPath.section].letter)
        top.didTapHeader = { [weak self] in
            self?.toggleGroup(at: indexPath.section)
        }
        return top
    }
}

class GridContactCell: UICollectionViewCell {
    static let id = "GridContactCell"

    private let nameText = UILabel()
    private let phoneText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }

    required init?(coder: NSCoder) { fatalError() }

    private func setupCell() {
        contentView.backgroundColor = .secondarySystemBackground
        contentView.layer.cornerRadius = 8
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray5.cgColor

        let pile = UIStackView(arrangedSubviews: [nameText, phoneText])
        pile.axis = .vertical
        pile.spacing = 4
        pile.alignment = .center
        pile.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(pile)
        NSLayoutConstraint.activate([
            pile.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            pile.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            pile.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 4)
        ])

        nameText.font = .boldSystemFont(ofSize: 16)
        phoneText.font = .systemFont(ofSize: 12)
        phoneText.textColor = .secondaryLabel
    }

    func configure(with contact: Contact) {
        nameText.text = contact.name
        phoneText.text = contact.phone
    }
}

class ContactHeaderView: UICollectionReusableView {
    static let id = "ContactHeaderView"

    var didTapHeader: (() -> Void)?
    private let titleText = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemGray6
        titleText.font = .boldSystemFont(ofSize: 18)
        titleText.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleText)

        NSLayoutConstraint.activate([
            titleText.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            titleText.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])

        let click = UITapGestureRecognizer(target: self, action: #selector(wasClicked))
        addGestureRecognizer(click)
    }

    required init?(coder: NSCoder) { fatalError() }

    func configure(text: String) { titleText.text = text }

    @objc private func wasClicked() { didTapHeader?() }
}
