//
//  NetworkManager.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit
import Alamofire

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://meme-api.herokuapp.com/gimme/"
    
    private var cache = NSCache<NSString, NSData>()
    
    let defaultMemes = 20
    let defailtSubreddits = ["memes", "dankmemes", "me_irl", "wholesomememes", "default"]
    
    private init() {}
    
    func fetchMemes(times count: String?, from subreddit: String?, completion: @escaping (Result<[Meme], AFError>) -> Void) {
        var endpoint = "\(baseURL)\(defaultMemes)"
        
        if let count = count, let subreddit = subreddit, subreddit != "default" {
            endpoint = "\(baseURL)\(subreddit)/\(count)"
        }
        
        AF.request(endpoint).validate().responseDecodable(of: MemesData.self) { dataResponse in
            switch dataResponse.result {
            case .success(let value):
                let memes = value.memes
                completion(.success(memes))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func downloadImage(from model: Meme, completion: @escaping (Result<Data, AFError>) -> Void) {
        guard let previewURL = model.preview?.last else { return }
        
        if let cachedImage = cache.object(forKey: previewURL as NSString) {
            completion(.success(cachedImage as Data))
            return
        }
        
        AF.download(previewURL).validate().responseData { responseData in
            switch responseData.result {
            case .success(let data):
                self.cache.setObject(data as NSData, forKey: previewURL as NSString)
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
