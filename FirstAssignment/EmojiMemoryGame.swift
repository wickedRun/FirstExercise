//
//  EmojiMemoryGame.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/05.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {   // ObservableObject 프로토콜은 implements 하는 것이 class여야 한다.
    @Published private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()   // 맨 앞에 저건 Property Wrapper
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["👻", "🎃", "🕷"]
        return MemoryGame<String>(numberOfPairsOfCards: emojis.count) { pairIndex in
            emojis[pairIndex]
        }
    }
    
//    var objectWillChange: ObservableObjectPublisher 이게 없어도 밑에 objectWillChange 에러 안남.
    
    // MARK: - Access to the Model
    
    var cards: Array<MemoryGame<String>.Card> {
        model.cards
    }
    
    // MARK: - Intent(s)
    
    func choose(card: MemoryGame<String>.Card) {
//        objectWillChange.send()  // 위에 @Published를 적으면 이거 안해줘도 됨. 써도 되긴 한다.
        model.choose(card: card)
    }
}
