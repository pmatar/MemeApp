//
//  Meme.swift
//  MemeApp
//
//  Created by Paul Matar on 07.04.2022.
//



struct MemesData: Decodable {
    let memes: [Meme]
}

struct Meme: Decodable {
    let url: String
    let title: String
}
