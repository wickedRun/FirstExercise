//
//  ContentView.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/04.
//

import SwiftUI

struct ContentView: View {
    var viewModel: EmojiMemoryGame
    var body: some View {
        return HStack {
            ForEach(viewModel.cards) { card in
                CardView(card: card).onTapGesture {
                    viewModel.choose(card: card)
                }.aspectRatio(2/3, contentMode: .fit)
            }
        }
            .padding()
            .foregroundColor(.orange)
    }
}

struct CardView: View {
    var card: MemoryGame<String>.Card

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if card.isFaceUp {
                    RoundedRectangle(cornerRadius: cornerRadious).stroke(lineWidth: edgeLineWidth)
                    RoundedRectangle(cornerRadius: cornerRadious).fill(Color.white)
                    Text(card.content)
                } else {
                    RoundedRectangle(cornerRadius: cornerRadious).fill()
                }
            }
            .font(Font.system(size: min(geometry.size.width, geometry.size.height) * fontSizeFactor))
        }
    }
    
    let fontSizeFactor: CGFloat = 0.75
    let edgeLineWidth: CGFloat = 3
    let cornerRadious: CGFloat = 10
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: EmojiMemoryGame())
    }
}
