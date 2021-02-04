//
//  EmojiMemoryGame.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/05.
//

import SwiftUI

class EmojiMemoryGame {
    private var model: MemoryGame<String> = EmojiMemoryGame.createMemoryGame()
    
    static func createMemoryGame() -> MemoryGame<String> {
        let emojis = ["👻", "🎃", "🕷", "🍬", "😈"]
        return MemoryGame<String>(numberOfPairsOfCards: Int.random(in: 2...emojis.count)) { pairIndex in
            emojis[pairIndex]
        }
    }
    
    var cards: Array<MemoryGame<String>.Card> {
        model.cards.shuffled()
    }
    
    func choose(card: MemoryGame<String>.Card) {
        model.choose(card: card)
    }
}
