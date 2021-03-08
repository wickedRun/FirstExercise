//
//  EmojiMemoryGameView.swift
//  Memorize
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
                    withAnimation(.linear(duration: 0.75)) {    // 이런걸 explicit animation 이라고 하는 듯.
                        viewModel.choose(card: card)
                    }
                }
                    .padding(5)
            }
                .padding()
                .foregroundColor(.orange)
            Button(action: {
                withAnimation(.easeInOut) {
                    viewModel.resetGame()
                }
            }, label: { Text("New Game") })
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
        
    @State private var animatedBonusRemaining: Double = 0   // 카드 뷰에서 애니메이션이 얼마나 남았는지 저장하는 변수.
    
    private func startBonusTimeAnimation() {
        // 1번(뷰에서만의 변수값을 모델의 값과 동기화하는 작업)과 2번(애니메이션 시작하는 작업)을 수행하는 함수.
        animatedBonusRemaining = card.bonusRemaining    // 1번
        withAnimation(.linear(duration: card.bonusTimeRemaining)) { // 2번.  // duration은 모델의 값으로. 
            animatedBonusRemaining = 0  // 0이 될때까지 withAnimation
        }
    }
    
    @ViewBuilder
    private func body(for size: CGSize) -> some View {
        if card.isFaceUp || !card.isMatched {
            ZStack {
                Group {
                    if card.isConsumeingBonusTime {
                        Pie(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(-animatedBonusRemaining*360-90),clockwise: true)
                            .onAppear {
                                self.startBonusTimeAnimation()
                            }
                    } else {
                        // 카드가 앞면인데 다음 카드를 뒤집었을때 카드를 맞췄을 때 bonusRemaining을 그대로 화면에 표시하기만 한다. 위와 다르게 .onAppear가 없고 endAngle이 다르다.
                        Pie(startAngle: Angle.degrees(0-90), endAngle: Angle.degrees(-card.bonusRemaining*360-90),clockwise: true)
                    }
                }
                    .padding(5)
                    .opacity(0.4)
                    .transition(.identity)  // identity는 수정 안하는 것 같음.  // 강의 끝부분에서 작성함.
                Text(card.content)
                    .font(.system(size: fontSize(for: size)))
                    .rotationEffect(Angle.degrees(card.isMatched ? 360 : 0))    // 이런걸 implicit animation이라 하는듯.
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
