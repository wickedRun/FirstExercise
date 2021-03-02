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
        
    private func body(for size: CGSize) -> some View {
        ZStack {
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                Pie(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(110-90),clockwise: true).padding(5).opacity(0.4)
                // Pie places between Rectangle and emoji
                // 실제로 반대방향으로 갈지라도 clockwise는 true이여야 한다.
                Text(card.content)
            } else {
                if !card.isMatched {
                    RoundedRectangle(cornerRadius: cornerRadius).fill()
                }
            }
        }.font(.system(size: fontSize(for: size)))
    }
    
    // MARK: - Drawing Constants
    
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
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
