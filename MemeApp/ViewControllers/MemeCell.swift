//
//  MemeCell.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

class MemeCell: UICollectionViewCell {
    @IBOutlet var memeImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func configure(with image: UIImage) {
            self.memeImageView.image = image
            self.activityIndicator.stopAnimating()
    }
}

