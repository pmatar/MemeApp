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
    
//    func fetchMemes(times count: String?, from subreddit: String?, completion: @escaping (Result<[Meme], NetworkError>) -> Void) {
//        var endpoint = "\(baseURL)\(defaultMemes)"
//
//        if let count = count, let subreddit = subreddit, subreddit != "default" {
//            endpoint = "\(baseURL)\(subreddit)/\(count)"
//        }
//
//        guard let url = URL(string: endpoint) else {
//            completion(.failure(.missingApiURL))
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                completion(.failure(.noJSONData))
//                return
//            }
//
//            do {
//                let memeData = try JSONDecoder().decode(MemesData.self, from: data)
//                DispatchQueue.main.async {
//                    completion(.success(memeData.memes))
//                }
//            } catch {
//                completion(.failure(.encodingJSONFailed))
//            }
//        }.resume()
//    }
    
    func downloadImage(from model: Meme, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let previewURL = model.preview?.last else {
            completion(.failure(.missingPreviewURL))
            return
        }
        
        guard let url = URL(string: previewURL) else {
            completion(.failure(.missingImageURL))
            return }
        
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString){
            DispatchQueue.main.async {
                completion(.success(cachedImage as Data))
            }
            return
        }
        
        URLSession.shared.downloadTask(with: url) { imageURL, _, error in
            guard let imageURL = imageURL, error == nil else {
                completion(.failure(.missingImageURL))
                return
            }
            
            do {
                let data = try Data(contentsOf: imageURL)
                self.cache.setObject(data as NSData, forKey: url.absoluteString as NSString)
                DispatchQueue.main.async {
                    completion(.success(data))
                }
            } catch {
                completion(.failure(.encodingImageFailed))
            }
        }.resume()
    }
    
    func fetchMemesWithAlamofire(times count: String?, from subreddit: String?, completion: @escaping (Result<[Meme], NetworkError>) -> Void) {
        var endpoint = "\(baseURL)\(defaultMemes)"
        
        if let count = count, let subreddit = subreddit, subreddit != "default" {
            endpoint = "\(baseURL)\(subreddit)/\(count)"
        }
        
        AF.request(endpoint)
            .validate()
            .responseJSON { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                    let memes = Meme.getMemes(from: value)
                    completion(.success(memes))
                case .failure(let error):
                    print(error)
                }
            }
    }
}

extension NetworkManager {
    enum NetworkError : String, Error {
        case noJSONData = "JSON Data is nil."
        case noImageData = "Image Data is nil."
        case encodingJSONFailed = "JSON encoding failed."
        case encodingImageFailed = "Image encoding failed"
        case missingApiURL = "API URL is nil."
        case missingImageURL = "Image URL is nil."
        case missingPreviewURL = "Preview URL is nil"
    }
}
