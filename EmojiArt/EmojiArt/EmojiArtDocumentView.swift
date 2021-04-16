//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var selectedEmojis: Set<EmojiArt.Emoji> = []
    
    @State private var chosenPalette: String = ""
    
    init(document: EmojiArtDocument) {
        self.document = document
//        self.chosenPalette = self.document.defaultPalette     // 컴파일 에러는 없지만 실행 x
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
//        이 방법이 이니셜라이져에서 State 변수를 초기화하는 올바른 방법이다. 이 State Struct를 직접적으로 setting 함으로써.
    }
    
    var body: some View {
        VStack {
            HStack {
                PaletteChooser(document: document, chosenPalette: $chosenPalette)
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
                            Text(emoji)
                                .font(Font.system(size: defaultEmojiSize))
                                .onDrag { return NSItemProvider(object: emoji as NSString) }
                        }
                    }
                }
//                .onAppear { self.chosenPalette = self.document.defaultPalette }
//                위에 이니셜라이저에서 처리해주므로 주석처리. onAppear도 괜찮게 동작하지만 위에 방법이 좀 더 property wrapper에 대해 교육적임.
            }
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    if self.isLoading {
                        Image(systemName: "hourglass").imageScale(.large).spinning()
                    } else {
                        ForEach(self.document.emojis) { emoji in
                            Text(emoji.text)
                                .border(self.isSelected(emoji) ? Color.black : Color.clear)
                                .font(animatableWithSize: emoji.fontSize * (self.isSelected(emoji) ? steadyStateZoomScale * gestureZoomScale : self.zoomScale))
                                .position(
                                    self.isSelected(emoji)
                                    ? self.position(for: emoji, in: geometry.size, duringGesture: gestureEmojiOffset)
                                    : self.position(for: emoji, in: geometry.size, duringGesture: nil))
                                .gesture(tapForToggle(in: emoji))
                                .gesture(longTapToRemove(of: emoji))
                                .gesture(dragToMoveEmoji(of: emoji))
                        }
                    }
                }
                .clipped()
                .gesture(self.tapToDeselect(in: geometry.size))
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                .onReceive(self.document.$backgroundImage) { image in
                    self.zoomToFit(image, in: geometry.size)
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @State private var steadyStateZoomScale: CGFloat = 1.0
    @GestureState private var gestureZoomScale: CGFloat = 1.0

    private var zoomScale: CGFloat {
        steadyStateZoomScale * (self.selectedEmojis.isEmpty ? gestureZoomScale : 1.0)
    }
    private func zoomGesture () -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                if self.selectedEmojis.isEmpty {
                    self.steadyStateZoomScale *= finalGestureScale
                } else {
                    self.selectedEmojis.forEach { emoji in
                        self.document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                }
            }
    }
    
    @State private var steadyStatePanOffset: CGSize = .zero
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.steadyStatePanOffset = self.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
            }
    }
    
    @GestureState private var gestureEmojiOffset: CGSize = .zero
        
    private func dragToMoveEmoji(of emoji: EmojiArt.Emoji) -> some Gesture {
        DragGesture()
            .updating($gestureEmojiOffset) { latestDragGestureValue, gestureEmojiOffset, transaction in
                if self.isSelected(emoji) {
                    gestureEmojiOffset = (self.zoomScale > 1.0 ? latestDragGestureValue.translation / self.zoomScale : latestDragGestureValue.translation)
                }
            }
            .onEnded { finalDragGestureValue in
                if self.selectedEmojis.isEmpty {
                    withAnimation {
                        self.document.moveEmoji(emoji, by: finalDragGestureValue.translation / self.zoomScale)
                    }
                    self.selectedEmojis.insert(emoji)
                } else {
                    if self.isSelected(emoji) {  
                        self.selectedEmojis.forEach { emoji in
                            self.document.moveEmoji(emoji, by: finalDragGestureValue.translation / self.zoomScale)
                        }
                    }
                }
            }
        
    }
    
    private func isSelected(_ emoji: EmojiArt.Emoji) -> Bool {
        self.selectedEmojis.contains(matching: emoji)
    }
    
    private func tapForToggle(in emoji: EmojiArt.Emoji) -> some Gesture {
        TapGesture(count: 1)
            .onEnded { _ in
                self.selectedEmojis.toggleMatching(emoji)
            }
    }
    
    private func longTapToRemove(of emoji: EmojiArt.Emoji) -> some Gesture {
        LongPressGesture(minimumDuration: 2)
            .onEnded { _ in
                self.selectedEmojis.remove(emoji)
                self.document.subEmoji(emoji)
            }
    }
    
    private func tapToDeselect(in size: CGSize) -> some Gesture {
        TapGesture(count: 1)
            .exclusively(before: doubleTapToZoom(in: size))
            .onEnded { _ in
                self.selectedEmojis.removeAll()
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    self.zoomToFit(self.document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.steadyStatePanOffset = .zero
            self.steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize, duringGesture gestureEmojiOffset: CGSize?) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * self.zoomScale, y: location.y * self.zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        if let offset = gestureEmojiOffset {
            location = CGPoint(x: location.x + offset.width, y: location.y + offset.height)
        }
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.backgroundURL = url
        }
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                self.document.addEmoji(string, at: location, size: defaultEmojiSize)
            }
        }
        return found
    }
    
    private let defaultEmojiSize: CGFloat = 40
}
