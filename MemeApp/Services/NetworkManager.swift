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
    
    func fetchMemes(times count: Int, completion: @escaping (Result<[Meme], NetworkError>) -> Void) {
        let endpoint = baseURL + "\(count)"
        
        guard let url = URL(string: endpoint) else {
            completion(.failure(.missingURL))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(.noData))
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
    
    func fetchImage(from model: Meme, completion: @escaping (Result<Data, NetworkError>) -> Void) {
        guard let url = URL(string: model.url) else {
            completion(.failure(.missingURL))
            return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data, error == nil {
                completion(.success(data))
            } else {
                completion(.failure(.noData))
                return
            }
        }.resume()
    }
    
    private init() {}
}

extension NetworkManager {
    enum NetworkError : String, Error {
        case noData = "Data is nil."
        case encodingFailed = "Data encoding failed."
        case missingURL = "URL is nil."
    }
}
