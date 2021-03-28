//
//  EmojiArt.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/27.
//

import Foundation

struct EmojiArt {
    var backgroundURL: URL?     // Swift library URL is doing that holds a URL like "https://"
//    private(set) var emojis = [Emoji]() // 하지만 이모지들의 위치와 크기를 바꾸기 때문에 private set은 안된다. 그래서 해결하기 위한 방법은 struct Emoji에 자동 생성 init을 사용하지 않고 따로 적어주어 fileprivate로 만들어주어 이 파일 내에서만 만들 수 있도록 함.
    var emojis = [Emoji]()
    
    struct Emoji: Identifiable {
        let text: String
        var x: Int  // offset from the center
        var y: Int  // offset from the center
        var size: Int
        let id: Int
//        var id = UUID() // UUID is a very unique identifier. Universe Unique ID and It's a little bit of overkill for Emojis in EmojiArt
        
        fileprivate init(text: String, x: Int, y: Int, size: Int, id: Int) {
            // fileprivate으로 하는 이유는 addEmoji함수에서 호출이 가능하도록 하기 위해.
            self.text = text
            self.x = x
            self.y = y
            self.size = size
            self.id = id
        }
    }
    private var uniqueEmojiId = 0
    
    mutating func addEmoji(_ text: String, x: Int, y: Int, size: Int) {
        uniqueEmojiId += 1
        emojis.append(Emoji(text: text, x: x, y: y, size: size, id: uniqueEmojiId))
    }
}
