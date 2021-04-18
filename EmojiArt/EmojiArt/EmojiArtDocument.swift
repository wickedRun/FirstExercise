//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI
import Combine  // this framework has the Cancellable, subscribing, publishing, all that stuff comes from there.

class EmojiArtDocument: ObservableObject, Hashable, Identifiable
{
    static func == (lhs: EmojiArtDocument, rhs: EmojiArtDocument) -> Bool {
        // lhs : left hand side, rhs: right hand side.
        lhs.id == rhs.id
    }
    
    let id: UUID
    
    func hash(into hasher: inout Hasher) {
//        hasher.combine(emojiArt)  // 이건 지나치기도 하고 문서가 바뀔때 마다 해쉬가 바뀔 수도 있기 때문에 좋지 않다.
        hasher.combine(id)
    }
    
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    @Published private var emojiArt: EmojiArt
        
//    주석처리.
//    private static let untitled = "EmojiArtDocument.Untitled"
    
    private var autosaveCancellable: AnyCancellable?
    
    //    init(id: UUID = UUID()) {
    // 이런 방법으로도 기본 값을 가질 수 있다.
    init(id: UUID? = nil) {
        // UUID?을 하는 이유로는 no argument로 init을 할 수 있게하기 때문이다.
        // 또한 UUID를 argument로 init 할 수 있다.
        // 유연성이 있기 때문에 이런 방식으로 한다.
        // 또한 id를 public 정보로 보여주기 싫을 때 이런 방법 사용.
        self.id = id ?? UUID()
        let defaultsKey = "EmojiArtDocument.\(self.id.uuidString)"
//        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: defaultsKey)) ?? EmojiArt()
        autosaveCancellable = $emojiArt.sink { emojiArt in
//            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
            UserDefaults.standard.set(emojiArt.json, forKey: defaultsKey)
        }
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    @Published var steadyStateZoomScale: CGFloat = 1.0
    @Published var steadyStatePanOffset: CGSize = .zero
    
    var emojis: [EmojiArt.Emoji] { return emojiArt.emojis }
    
    // MARK: - Intent(s)
    
    func addEmoji(_ emoji: String, at location: CGPoint, size: CGFloat) {
        emojiArt.addEmoji(emoji, x: Int(location.x), y: Int(location.y), size: Int(size))
    }
    
    func subEmoji(_ emoji: EmojiArt.Emoji) {
        emojiArt.subEmoji(emoji)
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
    
    var backgroundURL: URL? {
        get {
            emojiArt.backgroundURL
        }
        set {
            emojiArt.backgroundURL = newValue?.imageURL
            fetchBackgroundImageData()
        }
    }
    
    private var fetchImageCancellable: AnyCancellable?
    private func fetchBackgroundImageData() {
        backgroundImage = nil
        if let url = emojiArt.backgroundURL {
            fetchImageCancellable?.cancel()
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
