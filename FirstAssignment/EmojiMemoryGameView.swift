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
        VStack {
            Grid(viewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    withAnimation(.linear(duration: 0.75)) {
//                    withAnimation(.linear(duration: 2)) { // 동작을 확인할 때 너무 빠르면 보기 힘들기 때문에 duration을 2로 동작하게하여 확인 쉽게함.
                        viewModel.choose(card: card)
                    }
                }
                    .padding(5)
            }
                .padding()
                .foregroundColor(.orange)
            Button(action: {
                withAnimation(.easeInOut) {
//                withAnimation(.easeInOut(duration: 2)) {  // line 17과 동일.
                    viewModel.resetGame()
                }
            }, label: { Text("New Game") })     // red color인 이유는 화면에 보여지기 때문에. 이것에 대해 더 알아보려면 localizedString 도큐멘트 참조.
        }
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card

    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)
        }
    }
        
    @ViewBuilder
    private func body(for size: CGSize) -> some View {
        if card.isFaceUp || !card.isMatched {
            ZStack {
                Pie(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(110-90),clockwise: true).padding(5).opacity(0.4)
                Text(card.content)
                    .font(.system(size: fontSize(for: size)))
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))
                    .animation(card.isMatched ? Animation.linear(duration: 1).repeatForever(autoreverses: false) : .default)
            }
            .cardify(isFaceUp: card.isFaceUp)
            .transition(.scale)
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
