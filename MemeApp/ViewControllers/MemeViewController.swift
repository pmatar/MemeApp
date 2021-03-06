//
//  MemeViewController.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

protocol SettingsViewControllerDelegate: AnyObject {
    func setup(count: String, subreddit: String)
}

class MemeViewController: UICollectionViewController {
    @IBOutlet weak var settingsBarButton: UIBarButtonItem!
    
    private var refreshBarButton: UIBarButtonItem!
    private var refreshBarButtonActivityIndicator: UIBarButtonItem!
    
    private var count = String(NetworkManager.shared.defaultMemes)
    private var subreddit = "default"
    private var memes: [Meme] = [] {
        didSet{
            changeBarButton()
            backToTop()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserSettings()
        getMemes()
        setupBarButtons()
        setupNavigationBar()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settingsVC = segue.destination as? SettingsViewController else { return }
        settingsVC.delegate = self
        settingsVC.selectedCount = count
        settingsVC.selectedSubreddit = subreddit
    }
    
    @objc private func refreshTapped() {
        navigationItem.rightBarButtonItem = refreshBarButtonActivityIndicator
        getMemes()
    }
        
    // MARK: - UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return memes.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "memeCell", for: indexPath) as? MemeCell else {
            return UICollectionViewCell()
        }
        
        let meme = memes[indexPath.item]
        
        let representedIdentifier = meme.title ?? ""
        cell.representedIdentifier = representedIdentifier
        cell.activityIndicator.startAnimating()
        cell.activityIndicator.hidesWhenStopped = true
        cell.tag = indexPath.item
        
        NetworkManager.shared.downloadImage(from: meme) { result in
            switch result {
            case let .success(image):
                if (cell.representedIdentifier == representedIdentifier) && (cell.tag == indexPath.item) {
                    cell.configure(with: image)
                }
            case let .failure(error):
                print(error)
                cell.memeImageView.image = UIImage(named: "noImage")
                cell.activityIndicator.stopAnimating()
            }
        }
        return cell
    }
    
    // MARK: - UICollectionViewDelegate

    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let selectedCell = collectionView.cellForItem(at: indexPath) as? MemeCell else { return }
        guard let image = selectedCell.memeImageView.image else { return }
        
        let imageToShare = [image]
        let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = view
        present(activityViewController, animated: true, completion: nil)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension MemeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: UIScreen.main.bounds.width - 40, height: UIScreen.main.bounds.height * 0.5)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        UIScreen.main.bounds.height * 0.1
    }
}

// MARK: - Private Methods

extension MemeViewController {
    private func getMemes() {
        NetworkManager.shared.fetchMemes(times: count, from: subreddit) { [unowned self] result in
            
            switch result {
            case let .success(resultMemes):
                memes = resultMemes
                collectionView.reloadData()
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func changeBarButton() {
        if navigationItem.rightBarButtonItem == refreshBarButtonActivityIndicator {
            navigationItem.rightBarButtonItem = refreshBarButton
        }
    }
    
    private func setupNavigationBar() {
        let color = collectionView.backgroundColor
        navigationItem.rightBarButtonItem = refreshBarButton
        navigationController?.overrideUserInterfaceStyle = .light

        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = color
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        let button = UIButton()
        button.addTarget(self, action: #selector(backToTop), for: .touchUpInside)
        button.setTitle("Random Reddit Memes", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont(name: "Chalkduster", size: 15)
        button.sizeToFit()

        navigationItem.titleView = button
    }
    
    private func setupBarButtons() {
        let activityIndicator = UIActivityIndicatorView.init(style: .medium)
        activityIndicator.startAnimating()
        refreshBarButtonActivityIndicator = UIBarButtonItem(customView: activityIndicator)
        refreshBarButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshTapped))
        refreshBarButton.tintColor = .black
    }
    
    private func setupUserSettings() {
        let userSettings = StorageManager.shared.fetchSettings()
        
        if let userSubreddit = userSettings["subreddit"] {
            subreddit = userSubreddit
        }
        if let userCount = userSettings["count"] {
            count = userCount
        }
    }
    
    @objc private func backToTop() {
        collectionView.setContentOffset(CGPoint(x: 0, y: -collectionView.safeAreaInsets.top),
                                        animated: true)
    }
}

// MARK: - SettingsViewControllerDelegate

extension MemeViewController: SettingsViewControllerDelegate {
    func setup(count: String, subreddit: String) {
        self.count = count
        self.subreddit = subreddit
        getMemes()
    }
}
