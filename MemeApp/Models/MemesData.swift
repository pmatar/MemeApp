//
//  Meme.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//



//struct MemesData: Decodable {
//    let memes: [Meme]
//}

struct Meme: Decodable {
    let url: String?
    let title: String?
    let preview: [String]?
    
    init(manually rawData: [String: Any]) {
    url = rawData["url"] as? String
    title = rawData["title"] as? String
    preview = rawData["preview"] as? [String]
    }
    
    static func getMemes(from value: Any) -> [Meme] {
        guard let json = value as? [String: Any] else { return [] }
        guard let memesData = json["memes"] as? [[String: Any]] else { return [] }
        return memesData.compactMap { Meme(manually: $0) }
    }
}
