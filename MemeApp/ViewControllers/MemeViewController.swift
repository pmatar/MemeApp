//
//  MemeViewController.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

class MemeViewController: UICollectionViewController {
    
    private var memes: [Meme] = [] {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMemes()
    }
    
    // MARK: -UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell", for: indexPath) as? MemeCell else {
            return UICollectionViewCell()
        }
        
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidesWhenStopped = true
        cell.memeImageView.image = nil
        cell.tag = indexPath.item
        
        let meme = memes[indexPath.item]
        
        NetworkManager.shared.fetchImage(from: meme) { result in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    if cell.tag == indexPath.item {
                        cell.configure(with: image)
                    }
                }
            case let .failure(error):
                print(error.rawValue)
            }
        }
        return cell
    }
    @IBAction func refreshTapped(_ sender: UIBarButtonItem) {
        getMemes()
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MemeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40, height: 350)
    }
}

// MARK: - Private Methods

extension MemeViewController {
    private func getMemes() {
        NetworkManager.shared.fetchMemes(times: 20) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(memes):
                self.memes = memes
            case let .failure(error):
                print(error.rawValue)
            }
        }
    }
}
