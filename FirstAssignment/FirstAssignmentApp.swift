//
//  FirstAssignmentApp.swift
//  FirstAssignment
//
//  Created by wickedRun on 2021/02/04.
//

import SwiftUI

@main
struct FirstAssignmentApp: App {
    var body: some Scene {
        WindowGroup {
            let game = EmojiMemoryGame(theme: EmojiMemoryGame.Theme.sports)
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
