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
        _chosenPalette = State(wrappedValue: self.document.defaultPalette)
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
                                .font(animatableWithSize: emoji.fontSize * (self.isSelected(emoji) ? self.document.steadyStateZoomScale * gestureZoomScale : self.zoomScale))
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
//                    self.zoomToFit(image, in: geometry.size)
//                    지금 실행하는 버전은 zoomToFit에 버그가 없기 때문에 zoomToFit이 잘 실행된다. 그래서 주석처리.
                }
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
                .navigationBarItems(trailing: Button(action: {
                    if let url = UIPasteboard.general.url, url != self.document.backgroundURL {
                        self.confirmBackgroundPaste = true
                    } else {
                        self.explainBackgroundPaste = true
                    }
                }, label: {
                    Image(systemName: "doc.on.clipboard")
                        .imageScale(.large)
                        .alert(isPresented: self.$explainBackgroundPaste) {
                            return Alert(
                                title: Text("Paste Background"),
                                message: Text("Copy the URL of an image to the clip board and touch this button to make it the background of your document."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                }))
            }
            .zIndex(-1)
        }
        .alert(isPresented: self.$confirmBackgroundPaste) {
            Alert(
                title: Text("Paste Background"),
                message: Text("Replace your background with \(UIPasteboard.general.url?.absoluteString ?? "nothing")?."),
                primaryButton: .default(Text("OK")) {
                    self.document.backgroundURL = UIPasteboard.general.url
                },
                secondaryButton: .cancel()
            )
        }
    }
    
    @State private var explainBackgroundPaste = false
    @State private var confirmBackgroundPaste = false
    
    var isLoading: Bool {
        document.backgroundURL != nil && document.backgroundImage == nil
    }
    
    @GestureState private var gestureZoomScale: CGFloat = 1.0

    private var zoomScale: CGFloat {
        document.steadyStateZoomScale * (self.selectedEmojis.isEmpty ? gestureZoomScale : 1.0)
    }
    private func zoomGesture () -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, transaction in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                if self.selectedEmojis.isEmpty {
                    self.document.steadyStateZoomScale *= finalGestureScale
                } else {
                    self.selectedEmojis.forEach { emoji in
                        self.document.scaleEmoji(emoji, by: finalGestureScale)
                    }
                }
            }
    }
    
    @GestureState private var gesturePanOffset: CGSize = .zero
    
    private var panOffset: CGSize {
        (document.steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, transaction in
                gesturePanOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                self.document.steadyStatePanOffset = self.document.steadyStatePanOffset + (finalDragGestureValue.translation / self.zoomScale)
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
//        if let image = image, image.size.width > 0, image.size.height > 0 {
//        강의에서는 아이폰에서 이미지가 없어지는 버그로 인해 밑 조건으로 변경함.
        if let image = image, image.size.width > 0, image.size.height > 0, size.height > 0, size.width > 0{
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            self.document.steadyStatePanOffset = .zero
            self.document.steadyStateZoomScale = min(hZoom, vZoom)
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
