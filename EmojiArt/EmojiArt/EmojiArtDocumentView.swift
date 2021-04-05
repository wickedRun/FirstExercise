//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        VStack {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(EmojiArtDocument.palette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji)
                            .font(Font.system(size: defaultEmojiSize))
                            .onDrag { return NSItemProvider(object: emoji as NSString) }
                    }
                }
            }
                .padding(.horizontal)
            GeometryReader { geometry in
                ZStack {
                    Color.white.overlay(
                        // 좀 더 깨끗하게 혹은 보기 좋게 하기 위해 struct를 OptionalImage 파일로 새로 만듦. like CardView.
                        OptionalImage(uiImage: self.document.backgroundImage)
                            .scaleEffect(self.zoomScale)
                            .offset(self.panOffset)
                    )
                        .gesture(self.doubleTapToZoom(in: geometry.size))
                    ForEach(self.document.emojis) { emoji in
                        Text(emoji.text)
//                            .font(self.font(for: emoji))  // 추가한 Animatable~.Swift에 font() modifier를 사용하기위해 주석처리.
                            .font(animatableWithSize: emoji.fontSize * self.zoomScale)
                            .position(self.position(for: emoji, in: geometry.size))
                    }
                }
                // SwiftUI의 기본값은 View를 경계 밖으로 그릴 수 있도록 하는 것이다. 그래서 이 앱에서는 .clipped() modifier 적용.
                .clipped()  // .clipped() 는 View의 경계로 잘린다는 것을 의미한다.
                .gesture(self.panGesture())
                .gesture(self.zoomGesture())
                // commit: EmojiArt init 26 라인 코드 줄을 아래로 옮긴 이유는 semantically ZStack에 적용되기 때문에, 우리는 ZStack이 가장자리로 가는 것을 원하기 때문이다.
                // 그리고 우리는 ZStack의 어느 곳에서도 drop 하기를 원함.
                .edgesIgnoringSafeArea([.horizontal, .bottom])
                .onDrop(of: ["public.image", "public.text"], isTargeted: nil) { providers, location in // public.image 는 URI를 찾아 볼 것.
                    var location = geometry.convert(location, from: .global)
                    location = CGPoint(x: location.x - geometry.size.width/2, y: location.y - geometry.size.height/2)
                    location = CGPoint(x: location.x - self.panOffset.width, y: location.y - self.panOffset.height)
                    location = CGPoint(x: location.x / self.zoomScale, y: location.y / self.zoomScale)
                    return self.drop(providers: providers, at: location)
                }
            }
        }
    }
    
//    @State private var zoomScale: CGFloat = 1.0 // 1.0이 원본 2.0 두배 .5 절반. zoomScale 변수는 밑에 계산 변수로 만듬.
    @State private var steadyStateZoomScale: CGFloat = 1.0
    // pinch or drag gesture를 하기위해 바꿈.
    @GestureState private var gestureZoomScale: CGFloat = 1.0
    // 이 GestureState는 State 변수와 같은 타입일 필요가 없다.
    // 이 GestureState는 단지 핀치가 움직일 때마다 달라지는 정보이거나, 드래그가 움직일 때마다 변경되는 정보이거나, 계속 추적할 수 있게 해주는 정보이다.
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private func zoomGesture () -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale/*ourGestureZoomScaleInOut*/, transaction in
                // 위에 gestureZoomScale이 ourGestureScaleInOut으로 받게 되는데 이렇게 zoomScale을 작업하는 이유는 이 작업이 끝나고 나면 1.0으로 되돌아 가야하기 때문이다.
                // 이러한 이유 때문에 함수 인자의 이름을 @GestureState 변수의 이름과 똑같이 짓는다.
                gestureZoomScale = latestGestureScale
            }
            .onEnded { finalGestureScale in
                self.steadyStateZoomScale *= finalGestureScale
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
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {  // onEnded 끝났을 때이며 double tap이 끝나는 때는 두번째 tap finger가 뗐을 때다.
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
    
//    배경화면 zoomToFit으로 인해 폰트크기가 점프하는 것처럼 갑자기 크기가 변하는 것을 고치기위해 AnimatableSystem~.Swift를 넣었고 거기에 있는 font()를 사용하므로 이 함수는 사용 x.
//    private func font(for emoji: EmojiArt.Emoji) -> Font {
//        Font.system(size: emoji.fontSize * zoomScale)   // emoji 크기 또한 zoom으로 크기를 변경하므로 곱해준다.
//    }
    
    private func position(for emoji: EmojiArt.Emoji, in size: CGSize) -> CGPoint {
        var location = emoji.location
        location = CGPoint(x: location.x * self.zoomScale, y: location.y * self.zoomScale)
        location = CGPoint(x: location.x + size.width/2, y: location.y + size.height/2)
        location = CGPoint(x: location.x + panOffset.width, y: location.y + panOffset.height)
        return location
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint) -> Bool {
        var found = providers.loadFirstObject(ofType: URL.self) { url in
            self.document.setBackgroundURL(url)
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
