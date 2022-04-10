//
//  MemeViewController.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

class MemeViewController: UICollectionViewController {
    
    private var refreshBarButton: UIBarButtonItem!
    private var refreshBarButtonActivityIndicator: UIBarButtonItem!
    
    private var memes: [Meme] = [] {
        didSet{
            DispatchQueue.main.async {
                self.collectionView.reloadData()
                self.changeBarButton()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMemes()
        setupBarButtons()
        setupUI()
    }
    
    @objc func refreshTapped() {
        navigationItem.rightBarButtonItem = refreshBarButtonActivityIndicator
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
        
        let meme = memes[indexPath.item]
        
        let representedIdentifier = meme.title
        cell.representedIdentifier = representedIdentifier
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidesWhenStopped = true
        cell.memeImageView.image = nil
        cell.tag = indexPath.item
        
        NetworkManager.shared.downloadImage(from: meme) { result in
            switch result {
            case let .success(image):
                DispatchQueue.main.async {
                    if (cell.representedIdentifier == representedIdentifier) && (cell.tag == indexPath.item) {
                        cell.configure(with: image)
                    }
                }
            case let .failure(error):
                print(error.rawValue)
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // image to share
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? MemeCell else { return }
        guard let image = selectedCell.memeImageView.image else { return }
        
        // set up activity view controller
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        self.present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MemeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40, height: 450)
    }
}

// MARK: - Private Methods

extension MemeViewController {
    private func getMemes() {
        NetworkManager.shared.fetchMemes(times: 15) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case let .success(memes):
                self.memes = memes
            case let .failure(error):
                print(error.rawValue)
            }
        }
    }
    
    private func changeBarButton() {
        if navigationItem.rightBarButtonItem == refreshBarButtonActivityIndicator {
            navigationItem.rightBarButtonItem = refreshBarButton
        }
    }
    
    private func setupUI(){
        navigationController?.navigationBar.barTintColor = collectionView.backgroundColor
        navigationItem.rightBarButtonItem = refreshBarButton
        navigationController?.overrideUserInterfaceStyle = .light
    }
    
    private func setupBarButtons(){
        let activityIndicator = UIActivityIndicatorView.init(style: .medium)
        activityIndicator.startAnimating()
        refreshBarButtonActivityIndicator = UIBarButtonItem(customView: activityIndicator)
        
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        refreshBarButton.tintColor = .black
    }
}
