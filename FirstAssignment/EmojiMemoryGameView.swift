//
//  EmojiMemoryGameView.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/04.
//

import SwiftUI

struct EmojiMemoryGameView: View {
    @ObservedObject var viewModel: EmojiMemoryGame  // 이렇게 하면 objectWillChange.send 될때마다 뷰를 다시그린다.
    var body: some View {
        Grid(viewModel.cards) { card in
            CardView(card: card).onTapGesture {
                viewModel.choose(card: card)
            }
                .padding(5)
        }
            .padding()
            .foregroundColor(.orange)
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card

    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)   // self. 빼도 된다.
        }
    }
        
    @ViewBuilder    // <- 이거로 인해 interpret as list of Views (list of Views로 interpret된다.)
    private func body(for size: CGSize) -> some View {
        if card.isFaceUp || !card.isMatched {
            ZStack {
                Pie(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(110-90),clockwise: true).padding(5).opacity(0.4)
                // Pie places between Rectangle and emoji
                // 실제로 반대방향으로 갈지라도 clockwise는 true이여야 한다.
                Text(card.content)
                    .font(.system(size: fontSize(for: size)))
            }
            //        .modifier(Cardify(isFaceUp: card.isFaceUp)) // View에 extension을 추가하기전에 만든 ViewModifier(struct)를 호출하는 방법
            .cardify(isFaceUp: card.isFaceUp)         // View에 extension을 추가하여 호출하는 방법.
        }
    }
    
    // MARK: - Drawing Constants
    
    private func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.65
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = EmojiMemoryGame()
        game.choose(card: game.cards[0])
        return EmojiMemoryGameView(viewModel: game)
    }
}
