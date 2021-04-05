//
//  OptionalImage.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/04/03.
//

import SwiftUI

struct OptionalImage: View {
    var uiImage: UIImage?
    
    var body: some View {
        Group {
            if uiImage != nil {
                Image(uiImage: uiImage!)
            }
        }
    }
}
