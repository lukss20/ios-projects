//
//  NoteCell.swift
//  luchit22Notes
//
//  Created by lukss on 13.01.26.
//

import UIKit

class NoteCell: UICollectionViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var text: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = randomColor()
        title.font = UIFont.boldSystemFont(ofSize: 18)
        title.numberOfLines = 0
        text.font = UIFont.systemFont(ofSize: 15)
        text.numberOfLines = 0
    }

    func randomColor() -> UIColor {
        let colors: [UIColor] = [
            UIColor.systemYellow.withAlphaComponent(0.3),
            UIColor.systemGreen.withAlphaComponent(0.3),
            UIColor.systemBlue.withAlphaComponent(0.3),
            UIColor.systemPink.withAlphaComponent(0.3),
            UIColor.systemOrange.withAlphaComponent(0.3),
            UIColor.systemPurple.withAlphaComponent(0.3)
        ]
        return colors.randomElement() ?? UIColor.systemGray6
    }

    
}


