//
//  Meme.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//



struct APIData: Decodable {
    let data: MemesData
}

struct MemesData: Decodable {
        let memes: [Meme]
    }

struct Meme: Decodable {
    let url: String
}
