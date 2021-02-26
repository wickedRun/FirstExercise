//
//  EmojiMemoryGame.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/05.
//

import SwiftUI

class EmojiMemoryGame: ObservableObject {   // ObservableObject 프로토콜은 implements 하는 것이 class여야 한다.
    struct Theme {
        let name: String
        let emojis: [String]
        let color: Color
        
        static let halloween = Theme(name: "Halloween", emojis: ["👻", "🎃", "🕷"], color: Color.orange)
        static let animals = Theme(name: "Animals", emojis: ["🐼", "🐔", "🦄"], color: Color.pink)
        static let sports = Theme(name: "Sports", emojis: ["🏀", "🏈", "⚾"], color: Color.blue)
        static let faces = Theme(name: "Halloween", emojis: ["😀", "😢", "😉"], color: Color.yellow)
    }
    var score: Int {
        model.score
    }
    var theme: Theme
    @Published private var model: MemoryGame<String> //EmojiMemoryGame.createMemoryGame()   // 맨 앞에 저건 Property Wrapper
    
    init(theme: Theme) {
        self.theme = theme
        self.model = MemoryGame<String>(numberOfPairsOfCards: theme.emojis.count) { theme.emojis[$0] }
    }
    
//    func createMemoryGame(theme: Theme) -> MemoryGame<String> {
//        return MemoryGame<String>(numberOfPairsOfCards: theme.emojis.count) { theme.emojis[$0] }
//    }
    
    func restartMemoryGame() {
        let themes = [Theme.halloween, Theme.animals, Theme.sports, Theme.faces]
        let theme: Theme = themes.randomElement() ?? themes[0]
        model = MemoryGame<String>(numberOfPairsOfCards: theme.emojis.count) { theme.emojis[$0] }
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
