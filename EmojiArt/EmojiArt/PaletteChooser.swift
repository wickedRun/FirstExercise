//
//  PaletteChooser.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/04/13.
//

import SwiftUI

// 강의에서 App 이름을 EmojiArt 에서 Emoji Art로 변경함. 나는 변경 x.
struct PaletteChooser: View {
    @ObservedObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @State private var showPaletteEditor = false
    
    var body: some View {
        HStack {
            Stepper(
                onIncrement: {
                    self.chosenPalette = self.document.palette(after: self.chosenPalette)
                },
                onDecrement: {
                    self.chosenPalette = self.document.palette(before: self.chosenPalette)
                },
                label: { EmptyView() })
            Text(self.document.paletteNames[self.chosenPalette] ?? "")
            Image(systemName: "keyboard").imageScale(.large)
                .onTapGesture {
                    self.showPaletteEditor = true
                }
                // popover가 되길 원할때 showPaletteEditor를 true,
                // popover가 아닌 다른 곳을 터치하면 popover내에서 false로 설정하므로 Binding<Bool> 매개변수가 필요.
//              .popover(isPresented: self.$showPaletteEditor) {  // popover에서 sheet로 바꿈. iPad에서 present하는 또 다른 방법임
                .sheet(isPresented: self.$showPaletteEditor) {
                    // 화면에 띄운 sheet는 swipe down 해야 없어짐. popover처럼 바깥을 터치해도 나오지 않음.
                    // 아이패드에서는 popover가 더 어울림.
                    PaletteEditor(chosenPalette: self.$chosenPalette, isShowing: $showPaletteEditor)
                        // 밑에 @Binding으로 바꾸고 이니셜라이저의 $document로 전했을 때 나오는 에러문.
                        // Cannot convert value of type 'ObservedObject<EmojiArtDocument>.Wrapper' to expected argument type 'Binding<EmojiArtDocument>'
                        // 그래서
                        // 여기 popover의 () -> View 클로저 안인 별도의 뷰(separate View) 이므로 environmentObject로 해야한다.
                        // environmentObject를 설정하는 방법은 .environmentObject()를 해주면 된다. 전해받는 쪽에서는 @EnvironmentObject 변수가 필요.
                        .environmentObject(self.document)
                        .frame(minWidth: 300, minHeight: 500)
                }
        }
        .fixedSize(horizontal: true, vertical: false)
    }
}

struct PaletteEditor: View {
    @EnvironmentObject var document: EmojiArtDocument
    
    @Binding var chosenPalette: String
    @Binding var isShowing: Bool
    @State private var paletteName: String = ""
    @State private var emojisToAdd: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Palette Editor").font(.headline).padding()
                HStack {
                    Spacer()
                    Button(action: {
                        self.isShowing = false
                    }, label: { Text("Done") }).padding()
                }
            }
            Divider()
            Form {  // Form이란 아이폰 설정에서처럼 항목들 별로 나눈 UI이다.
                Section {
//                Section(header: Text("Palette Name")) { -> header는 중복되는 일이므로 없애줌.
                    //            Text(self.document.paletteNames[self.chosenPalette] ?? "").padding()
                    //            TextField로 변경
                    //            TextField("Palette Name", text: $paletteName)
                    // label: "Palette Name" 은 채워진 텍스트가 없는 경우에 hint 처럼 나온다.
                    // 그 속에 텍스트를 넣고 시작하고 싶다면 binding 변수에 값을 넣어 초기화 시키면 된다.
                    // editing 할때 약간 scroll 되는 것은 키보드를 방해하지 않기 위해 scroll 된다.
                    //            Editing을 적용하기 위해서 onEditingChanged: (Bool) -> Void 인 argument를 넣어준다.
                    //            Bool 변수는 편집을 시작할때는 true, 편집을 마칠때는 false.
                    TextField("Palette Name", text: $paletteName, onEditingChanged: { began in
                        if !began {
                            self.document.renamePalette(self.chosenPalette, to: self.paletteName)
                        }
                    })
//                    .padding()    // Form 은 모든 패딩을 처리하고 이 모든 것을 그 자체로 배치하는 것이기 때문에 padding 삭제 처리.
                    TextField("Add Emoji", text: $emojisToAdd, onEditingChanged: { began in
                        if !began {
                            self.chosenPalette = self.document.addEmoji(self.emojisToAdd, toPalette: self.chosenPalette)
                            self.emojisToAdd = ""
                        }
                    })
                }
//                .padding()
                Section(header: Text("Remove Emoji")) {
//                    VStack {
//                        ForEach(chosenPalette.map { String($0) }, id: \.self) { emoji in
//                            Text(emoji)
//                                .onTapGesture {
//                                    self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
//                                }
//                        }
//                    }
//                    Grid로 바꾸기 위해 삭제 처리.
                    Grid(chosenPalette.map { String($0) }, id: \.self) { emoji in
                        Text(emoji).font(Font.system(size: self.fontSize))
                            .onTapGesture {
                                self.chosenPalette = self.document.removeEmoji(emoji, fromPalette: self.chosenPalette)
                            }
                    }
                    .frame(height: self.height)
                }
            }
//            Spacer()  // Form 추가 후 삭제처리.
        }
        .onAppear { self.paletteName = self.document.paletteNames[self.chosenPalette] ?? "" }
    }
    
    // MARK: - Drawing Constants
    
    var height: CGFloat {
        CGFloat((chosenPalette.count - 1) / 6) * 70 + 70
    }
    
    let fontSize: CGFloat = 40
}

struct PaletteChooser_Previews: PreviewProvider {
    static var previews: some View {
        PaletteChooser(document: EmojiArtDocument(), chosenPalette: .constant(""))
    }
}
