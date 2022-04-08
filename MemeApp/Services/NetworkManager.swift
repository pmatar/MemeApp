//
//  NetworkManager.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//

import UIKit
class NetworkManager {
    static let shared = NetworkManager()
    
    func fetchMemes(completionHandler: @escaping ([Meme]) -> Void) {
        guard let url = URL(string: DuckApi.getMemes.rawValue) else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "no")
                return
            }
            do {
                let memeData = try JSONDecoder().decode(APIData.self, from: data)
                completionHandler(memeData.data.memes)
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func fetchImage(_ model: Meme, completionHandler: @escaping (UIImage) -> Void) {
        guard let url = URL(string: model.url) else { return }
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data else {
                print(error?.localizedDescription ?? "No error description")
                return
            }
            guard let image = UIImage(data: data) else { return }
            completionHandler(image)
        }.resume()
    }
    
    private init() {}
}

enum DuckApi: String {
    case randomJSONImage = "https://random-d.uk/api/random"
    case randomImage = "https://random-d.uk/api/randomimg"
    case getMemes = "https://api.imgflip.com/get_memes"
}
