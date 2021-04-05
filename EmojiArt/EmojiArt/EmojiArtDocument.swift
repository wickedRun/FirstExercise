//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI

class EmojiArtDocument: ObservableObject
{
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    // @Published // workaround for property observer problem with property wrappers 강의에선 버그가 있어서 같이 쓰지 못한다.
    @Published private var emojiArt: EmojiArt {
//        willSet {
//            objectWillChange.send()
//        }
//        위에 주석으로 인한 문제로 objectWillChange.send() 수동으로 해준다.
        didSet {
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)   // json이 nil이면 forKey는 clear out 될 것이다.
        }
    }
    
    // UserDefaults(사용자 기본 설정)는 사용자 기본 설정에 넣으면 디스크로 바로 실행되어 기록되지 않고, 버퍼링하여 편리한 시간에 기록합니다. 즉, 바로바로 즉시 갱신이 아니라는 말.
    // 다른 앱으로 전환할 때는 버퍼에 있는 것을 디스크로 저장함.
    // 그래서 쓰기를 하고 바로 앱을 끄면 저장하는 작업을 하기 전에 앱이 죽어서 저장이 안된다. 앱이 죽기전에 쓰기 작업을 하여야 보존할 수 있다.
    
    private static let untitled = "EmojiArtDocument.Untitled"
    // static let으로 만든 이유는 하드코딩은 위험하기 때문에 forKey의 값을 동일하게 유지하기 위해서 적어둔 것이다. 나중에는 도큐먼트들을 선택할 수 있게 만든다면 지우게 될 코드임.
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { return emojiArt.emojis}
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArt.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].x += Int(offset.width)
            emojiArt.emojis[index].y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArt.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.firstIndex(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale).rounded(.toNearestOrEven))
        }
    }
    
    func setBackgroundURL(_ url: URL?) {
        emojiArt.backgroundURL = url?.imageURL
        fetchBackgroundImageData()
    }
    
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            DispatchQueue.global(qos: .userInitiated).async {
                if let imageData = try? Data(contentsOf: url) {
                    if url == self.emojiArt.backgroundURL {
                        DispatchQueue.main.async {
                            self.backgroundImage = UIImage(data: imageData)
                        }
                    }
                }
            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
