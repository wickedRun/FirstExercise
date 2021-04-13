//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI
import Combine  // this framework has the Cancellable, subscribing, publishing, all that stuff comes from there.

class EmojiArtDocument: ObservableObject
{
    static let palette: String = "⭐️⛈🍎🌏🥨⚾️"
    
    @Published private var emojiArt: EmojiArt
        
    private static let untitled = "EmojiArtDocument.Untitled"
    
    private var autosaveCancellable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArt(json: UserDefaults.standard.data(forKey: EmojiArtDocument.untitled)) ?? EmojiArt()
        // 아래 let cancellable 였지만 이 변수가 사라지면 사라지기 때문에 위에 autosaveCancellable 변수를 만들어 할당해준다.
        autosaveCancellable = $emojiArt.sink { emojiArt in
//            print("\(emojiArt.json?.utf8 ?? "nil")")  // 변경 확인을 위한 print문.
            UserDefaults.standard.set(emojiArt.json, forKey: EmojiArtDocument.untitled)
        }
        fetchBackgroundImageData()
    }
    
    @Published private(set) var backgroundImage: UIImage?
    
    var emojis: [EmojiArt.Emoji] { return emojiArt.emojis}
    
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
            fetchImageCancellable?.cancel() // 다시 드래그를 할때 이전 이미지 불러오는 것을 취소.
            fetchImageCancellable = URLSession.shared.dataTaskPublisher(for: url)
                .map { data, urlResponse in UIImage(data: data) }
                .receive(on: DispatchQueue.main)
                .replaceError(with: nil)
                .assign(to: \EmojiArtDocument.backgroundImage, on: self)
            
//            아래 코드를 위 코드로 한줄로 변경으로 인해 주석처리.
//            let session = URLSession.shared                       // URLSession의 static var shared 사용.
//            let publisher = session.dataTaskPublisher(for: url)   // session의 함수를 통해 publisher를 받음.
//                .map { data, urlResponse in UIImage(data: data) } // map 함수를 통해 데이터를 걸러줌.
//                .receive(on: DispatchQueue.main)                  // 아래 코드에서 main으로 ui를 변경하므로 여기서도 main으로 받음.
//                .replaceError(with: nil)                          // 따로 에러처리 하지않고 Nil로 받음.
//            fetchImageCancellable = publisher.assign(to: \EmojiArtDocument.backgroundImage, on: self) // sink 대신 assign으로 image 배정.
            
//            URLSession으로 가져오는 코드로 바꿈으로써 주석처리.
//            DispatchQueue.global(qos: .userInitiated).async {
//                if let imageData = try? Data(contentsOf: url) {
//                    if url == self.emojiArt.backgroundURL {
//                        DispatchQueue.main.async {
//                            self.backgroundImage = UIImage(data: imageData)
//                        }
//                    }
//                }
//            }
        }
    }
}

extension EmojiArt.Emoji {
    var fontSize: CGFloat { CGFloat(self.size) }
    var location: CGPoint { CGPoint(x: CGFloat(x), y: CGFloat(y)) }
}
