//
//  Cardify.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/03/03.
//

import SwiftUI

struct Cardify: AnimatableModifier {
    var rotation: Double
    
    var isFaceUp: Bool {
        rotation < 90
    }
    
    var animatableData: Double {    // system과 소통하는 implement 변수. ㅇ
        get{ return rotation }
        set{ rotation = newValue }
    }
    
    init(isFaceUp: Bool) {
        rotation = isFaceUp ? 0 : 180
    }
    
    func body(content: Content) -> some View {
        ZStack {
            Group {
                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
                content
            }
                .opacity(isFaceUp ? 1 : 0)
            RoundedRectangle(cornerRadius: cornerRadius).fill()
                .opacity(isFaceUp ? 0 : 1)
            
////         아래코드일때는 그림을 맞췄을 때 방금 막 뒤집은 카드가 animation은 변경된 상태에 대해서만 동작하기 때문에 (이미 isMatched가 true이기 때문에) implicit animation이 동작하지 않는다.  그래서 위의 코드처럼 opacity를 건드려 show/hide로 동작하게 한다.
//            if isFaceUp {
//                RoundedRectangle(cornerRadius: cornerRadius).fill(Color.white)
//                RoundedRectangle(cornerRadius: cornerRadius).stroke(lineWidth: edgeLineWidth)
//                content
//            } else {
//                RoundedRectangle(cornerRadius: cornerRadius).fill()
//            }
        }
        .rotation3DEffect(Angle.degrees(rotation), axis: (0, 1, 0))
    }
    
    private let cornerRadius: CGFloat = 10
    private let edgeLineWidth: CGFloat = 3
}

extension View {
    func cardify(isFaceUp: Bool) -> some View {
        self.modifier(Cardify(isFaceUp: isFaceUp))
    }
}
