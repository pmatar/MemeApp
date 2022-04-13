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
    
    var representedIdentifier: String = ""
    
    override func prepareForReuse() {
        memeImageView.image = nil
    }
    
    func configure(with data: Data) {
        memeImageView.image = UIImage(data: data)
        activityIndicator.stopAnimating()
    }
}

