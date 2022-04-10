//
//  NetworkManager.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://meme-api.herokuapp.com/gimme/"
    
    private var cache = NSCache<NSString, NSData>()
    
    private init() {}
    
    func fetchMemes(times count: Int, completion: @escaping (Result<[Meme], NetworkError>) -> Void) {
        let endpoint = baseURL + "\(count)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.missingApiURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.noJSONData))
                return
            }
            
            do {
                let memeData = try JSONDecoder().decode(MemesData.self, from: data)
                completion(.success(memeData.memes))
            } catch {
                completion(.failure(.encodingFailed))
            }
        }.resume()
    }
    
    func downloadImage(from model: Meme, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = URL(string: model.url) else {
            completion(.failure(.missingImageURL))
            return }
        
        if let cachedImage = cache.object(forKey: url.absoluteString as NSString){
            completion(.success(cachedImage as Data))
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
                completion(.success(data))
            } catch {
                completion(.failure(.encodingFailed))
            }
        }.resume()
    }
}

extension NetworkManager {
    enum NetworkError : String, Error {
        case noJSONData = "JSON Data is nil."
        case noImageData = "Image Data is nil."
        case encodingFailed = "Data encoding failed."
        case missingApiURL = "API URL is nil."
        case missingImageURL = "Image URL is nil."
    }
}
