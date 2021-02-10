//
//  MemoryGame.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/05.
//

import Foundation

struct MemoryGame<CardContent> where CardContent: Equatable {
    var cards: Array<Card>
    
    var indexOfTheOneAndOnlyFaceUpCard: Int? {
        get {
            cards.indices.filter { cards[$0].isFaceUp }.only
//      여기는 range의 filter 메소드와 클로저 매개변수로 생략가능.
//            var faceUpCardIndices = [Int]()
//            for index in cards.indices {
//                if cards[index].isFaceUp {
//                    faceUpCardIndices.append(index)
//                }
//            }
//      여기는 Array+Only에서 Array Extension으로 var only를 추가하여 생략가능
//            if faceUpCardIndices.count == 1 {
//                return faceUpCardIndices.first
//            } else {
//                return nil
//            }
        }
        set {
            for index in cards.indices {
                cards[index].isFaceUp = index == newValue   // 밑에 코드가 이 한줄로 줄일 수 있다.
//                if index == newValue {      // newValue is the special var. 이 set 괄호 안에서만 사용가능.
//                    cards[index].isFaceUp = true
//                } else {
//                    cards[index].isFaceUp = false
//                }
            }
        }
    }
    
    mutating func choose(card: Card) {  // self.속성을 변경하려할때 mutating을 써줘야한다. 값 타입이므로 self.으로 접근해야하며 mutating을 사용하여 바꾸어야함.
        print("card chosen: \(card)")
        if let chosenIndex: Int = cards.firstIndex(matching: card), !cards[chosenIndex].isFaceUp, !cards[chosenIndex].isMatched {
            // comma는 if문이 중첩되있는 것처럼 앞에 chosenIndex 조건문을 실행하고 그 다음에 조건문 실행함.
            if let potentialMatchIndex = indexOfTheOneAndOnlyFaceUpCard {
                if cards[chosenIndex].content == cards[potentialMatchIndex].content {
                    cards[chosenIndex].isMatched = true
                    cards[potentialMatchIndex].isMatched = true
                }
//                indexOfTheOneAndOnlyFaceUpCard = nil // 이 value는 getset을 통해서 앱에서 현재 값으로 sync된다. for문을 돌아서 계산된 값이 설정됨.
                self.cards[chosenIndex].isFaceUp = true
            }
            else {
//                for index in cards.indices {          // 이 포문 또한 set에 있기 때문에. 주석처리.
//                    cards[index].isFaceUp = false
//                }
                indexOfTheOneAndOnlyFaceUpCard = chosenIndex
            }
//            self.cards[chosenIndex].isFaceUp = true 이 줄이 if let 구문 밑으로 옮기.
        }
    }
    
//    이 메소드는 Grid.swift에서 Array의 extension으로 구현함.
//    func index(of card: Card) -> Int {
//        for index in 0 ..< self.cards.count {
//            if self.cards[index].id == card.id {
//                return index
//            }
//        }
//        return 0    // TODO: bogus!
//        // 위에 M index(of:)을 누르면 (TODO :) 주석이 나옴. Mark도 동일함. 그걸 클릭하면 바로 이 줄로 이동함.
//    }
    
    init(numberOfPairsOfCards: Int, cardContentFactory: (Int) -> CardContent) {
        cards = Array<Card>()
        for pairIndex in 0..<numberOfPairsOfCards {
            let content = cardContentFactory(pairIndex)
            cards.append(Card(content: content, id: pairIndex*2))
            cards.append(Card(content: content, id: pairIndex*2+1))
        }
    }
    
    struct Card: Identifiable {
        var isFaceUp: Bool = false
        var isMatched: Bool = false
        var content: CardContent
        var id: Int
    }
}
