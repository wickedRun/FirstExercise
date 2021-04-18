//
//  EmojiArtDocumentChooser.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/04/17.
//

import SwiftUI

struct EmojiArtDocumentChooser: View {
    @EnvironmentObject var store: EmojiArtDocumentStore
    // ObservableObject로 할 수 있겠지만 EnvironmentObject로 하는 것이 다른 뷰를 선택할 수 있는 최상위 뷰용으로 사용하는 것이 일반적이다.
//    @Environment(\.editMode) var editMode
//    이런 방식으로 editmode를 set 할 수 있지만 여기서는 이렇게 하지 않음.
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            // NavigationView 이하에 꼭 List일 필요 없다. 때때로 Form이 올 수도 있다.
            List {
                // List는 약간 VStack과 비슷하다. 그러나 훨씬 파워풀임.
                // So List, kind of like a VStack feels a little bit like a VStack, but it's much more powerful that it creates a big scrollable list with separators and all that stuff.
                // UIKit에서는 TableView 라고 불렀던 것.
                ForEach(store.documents) { document in
                    // Link를 걸면 화살표가 생김.
                    NavigationLink(destination: EmojiArtDocumentView(document: document)
                                        .navigationBarTitle(self.store.name(for: document))
                    ) {
//                        Text(self.store.name(for: document))  // 편집가능하도록 바꾸기 위해 주석처리.
                        EditableText(self.store.name(for: document), isEditing: self.editMode.isEditing) { name in
                            self.store.setName(name, for: document)
                        }
                    }
                }
                .onDelete { indexSet in
                    // indexSet은 다른 컬렉션에 있는 요소의 인덱스를 나타내는 고유한 정수 값의 컬렉션입니다.
                    indexSet.map { self.store.documents[$0] }.forEach { document in
                        self.store.removeDocument(document)
                    }
                }
            }
//            .environment(\.editMode, $editMode)   // 이 함수는 editbutton이 없으면 안된다. 그리고 이 위치에 있으면 editButton이 없기 때문에 environment 설정 안됨.
            .navigationBarTitle(self.store.name)
            .navigationBarItems(
                leading: Button(action: {
                    self.store.addDocument()
                }, label: {
                    Image(systemName: "plus").imageScale(.large)
                }),
                trailing: EditButton()
            )
            .environment(\.editMode, $editMode)     // 여기에 있어야 한다. EditButton 뒤에. 42번 라인에 설명 더 있음.
            // 또 중요한 것은 .environment는 호출한 보기에서만 적용된다는 것이다.
            // 그리고 EditButton이 없으면 안된다.
        }
    }
}

struct EmojiArtDocumentChooser_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentChooser()
    }
}
