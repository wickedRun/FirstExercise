//
//  MemorizeApp.swift
//  Memorize
//
//  Created by wickedRun on 2021/02/04.
//

import SwiftUI

@main
struct MemorizeApp: App {
    var body: some Scene {
        WindowGroup {
            let game = EmojiMemoryGame()
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
