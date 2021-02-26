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
        VStack{
            HStack{
                Button("Restart"){
                    viewModel.restartMemoryGame()
                }.frame(width: 175, alignment: .leading)
                Text(viewModel.theme.name)
                Spacer()
                Text("\(viewModel.score)")
            }
            Grid(viewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    viewModel.choose(card: card)
                }
                .padding(5)
            }
            .navigationBarTitle(viewModel.theme.name)
            .padding()
            .foregroundColor(viewModel.theme.color)
        }
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card

    var body: some View {
        GeometryReader { geometry in
            self.body(for: geometry.size)   // self. 빼도 된다.
        }
    }
        
    func body(for size: CGSize) -> some View {
        ZStack {        // ZStack 이나 HStack 같은 ViewBuilder 안에서는 var 변수는 들어갈 수 없다.
            if card.isFaceUp {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                Text(card.content)
            } else {
                if !card.isMatched {    // card의 isMatched 가 true이면 아예 그리지 않기 때문에 UI에서 사라진다.
                    RoundedRectangle(cornerRadius: cornerRadius).fill()
                }
            }
        }.font(.system(size: fontSize(for: size)))
    }
    
    // MARK: - Drawing Constants
    
    let cornerRadius: CGFloat = 10
    let edgeLineWidth: CGFloat = 3
//    let fontScaleFactor: CGFloat = 0.75   // 밑에 fontSize에 필요한 것이므로 함수에서 선언하거나 아예 없애도 된다.
    func fontSize(for size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.75 // or fontSacleFactor
    }
    
    // MARK: - Before make the func body, var body.
//    var body: some View {
//        GeometryReader { geometry in
//            ZStack {        // ZStack 이나 HStack 같은 ViewBuilder 안에서는 var 변수는 들어갈 수 없다.
//                if card.isFaceUp {
//                    RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
//                    RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
//                    Text(card.content)
//                } else {
//                    RoundedRectangle(cornerRadius: cornerRadius).fill()
//                }
//            }.font(.system(size: min(geometry.size.width, geometry.size.height) * fontScaleFactor))    // 너비와 높이중에 최소값을 반환하며 리턴값에 0.75를 곱한다. 너무 딱 맞기 때문에.
//        }
//    }
//    self.을 쓰지 않기 위해 이런식으로 만든 것 같지만 지금은 self. 안써도 된다. 코드가 어떻게 보일지에 따라 이렇게 할지 저렇게 할지 정하면 된다.
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiMemoryGameView(viewModel: EmojiMemoryGame(theme: EmojiMemoryGame.Theme.sports))
    }
}
