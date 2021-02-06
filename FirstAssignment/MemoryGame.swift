//
//  MemoryGame.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/05.
//

import Foundation

struct MemoryGame<CardContent> {
    var cards: Array<Card>
    
    mutating func choose(card: Card) {  // self.속성을 변경하려할때 mutating을 써줘야한다.
        print("card chosen: \(card)")
        let chosenIndex: Int = self.index(of: card)
        self.cards[chosenIndex].isFaceUp = !self.cards[chosenIndex].isFaceUp
    }
    
    func index(of card: Card) -> Int {
        for index in 0 ..< self.cards.count {
            if self.cards[index].id == card.id {
                return index
            }
        }
        return 0    // TODO: bogus!
        // 위에 M index(of:)을 누르면 (TODO :) 주석이 나옴. Mark도 동일함. 그걸 클릭하면 바로 이 줄로 이동함.
    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = true
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}
