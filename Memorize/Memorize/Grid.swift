//
//  Grid.swift
//  Memorize
//
//  Created by wickedRun on 2021/02/08.
//

import SwiftUI

struct Grid<Item, ItemView>: View where Item: Identifiable, ItemView: View {
    private var items: [Item]
    private var viewForItem: (Item) -> ItemView
    
    init(_ items: [Item], viewForItem: @escaping (Item) -> ItemView) {  // @escaping을 써주는 이유는 서로 포인터를 가리키지 않도록 하기위해서.
        self.items = items
        self.viewForItem = viewForItem
    }
    
    var body: some View {
        GeometryReader { geometry in
            body(for: GridLayout(itemCount: self.items.count, in: geometry.size))
        }
    }
    
    // MARK: - View에서와 같은 방법임, self를 안써줘도 되는 지금은 이렇게 굳이 바꾸지 않아도 될 것 같다. 그저 내 생각임.
    
    private func body(for layout: GridLayout) -> some View{
        ForEach(items) { item in
            self.body(for: item, in: layout)
        }
    }
    
    private func body(for item: Item, in layout: GridLayout) -> some View {
        let index = items.firstIndex(matching: item)!
        return viewForItem(item)
            .frame(width: layout.itemSize.width, height: layout.itemSize.height)
            .position(layout.location(ofItemAt: index))
    }
//    nil일 경우 런타임오류가 안나게 하기 위해서 하는 방법이지만 할 필요가 없다. 그래서 주석처리하였음.
//        return Group {      // Group은 그룹화하는 ViewBuilder임. 더 알고 싶으면 documentation 참조.
//            if index != nil {       // nil이면 빈 뷰를 리턴함. 하지만 강의에서는 nil일 경우를 don't care함.
//                viewForItem(item)
//                    .frame(width: layout.itemSize.width, height: layout.itemSize.height)
//                    .position(layout.location(ofItemAt: index!))
//            }
//        }
}
