//
//  MemeViewController.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

class MemeViewController: UICollectionViewController {
    
    let net = NetworkManager.shared
    
    private var memes: [Meme] = [] {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        net.fetchMemes() { memes in
            self.memes = memes
        }
        
        super.viewDidLoad()
    }
    
    // MARK: -UICollectionViewDataSource

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell",
                                                          for: indexPath) as? MemeCell
        else { return UICollectionViewCell() }
        
        let meme = memes[indexPath.item]
        
        net.fetchImage(meme) { image in
            DispatchQueue.main.async {
                cell.configure(with: image)
            }
        }
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidesWhenStopped = true
        return cell
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MemeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width/2.2, height: 200)
    }
}

