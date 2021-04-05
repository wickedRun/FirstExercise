//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/27.
//

import Foundation

struct EmojiArt: Codable/*Encodable, Decodable 둘다 conform하는 Codable로 하나로 protocol 작성 Emoji도 동일*/ {
    var backgroundURL: URL?
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable, Codable {
        let text: String
        var x: Int
        var y: Int
        var size: Int
        let id: Int
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    
    var json: Data? {
        return try? JSONEncoder().encode(self)
    }
    
    init?(json: Data?) {
        if json != nil, let newEmojiArt = try? JSONDecoder().decode(EmojiArt.self, from: json!) {
            self = newEmojiArt
        } else {
            return nil
        }
    }
    
    // Failable init을 만들었기 때문에 기본 init을 따로 만들어 주어야 한다.
    init() { }
    
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1 
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
