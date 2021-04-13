//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/04/13.
//

import SwiftUI

// 강의에서 App 이름을 EmojiArt 에서 Emoji Art로 변경함.
struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    
    var body: some View {
        HStack {
            // Stepper is little plus minus button.
            Stepper(
                onIncrement: {
                    self.chosenPalette = self.document.palette(after: self.chosenPalette)
                },
                onDecrement: {
                    self.chosenPalette = self.document.palette(before: self.chosenPalette)
                },
                label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
        }
        .fixedSize(horizontal: true, vertical: false)
        // fixedSize means that it's going to kind of size itself to fit and not going to use any extra space that's offered to it.
//        .onAppear { self.chosenPalette = self.document.defaultPalette }
        // main View에서도 onAppear를 하고 있으므로. 주석처리.
    }
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: .constant("")) // live data를 넣지 못하니 Binding.constant로 넣어줌.
    }
}
