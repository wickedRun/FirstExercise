//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/03/26.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    var body: some Scene {
        WindowGroup {
            let store = EmojiArtDocumentStore()
            EmojiArtDocumentChooser().environmentObject(store)
//            EmojiArtDocumentView(document: EmojiArtDocument())
        }
    }
    
//    EmojiArtDocumentStore 내에서 다 UserDefault에 저장해주므로 한번만 해줘도 된다.
//    하지만 내 환경에서는
//    아래 로그가 뜨면서 readyStore()와 EmojiArtDocumentStore()가 따로 논다. 해당 문제는 찾아봐야 할듯.
//    2021-04-18 17:17:44.989824+0900 EmojiArt[80845:8549283] [LayoutConstraints] Unable to simultaneously satisfy constraints.
//        Probably at least one of the constraints in the following list is one you don't want.
//        Try this:
//            (1) look at each constraint and try to figure out which you don't expect;
//            (2) find the code that added the unwanted constraint or constraints and fix it.
//    (
//        "<NSLayoutConstraint:0x600001502d00 'BIB_Trailing_CB_Leading' H:[_UIModernBarButton:0x7f965fd1b500]-(6)-[_UIModernBarButton:0x7f965fd174f0'Emoji Art']   (active)>",
//        "<NSLayoutConstraint:0x600001502d50 'CB_Trailing_Trailing' _UIModernBarButton:0x7f965fd174f0'Emoji Art'.trailing <= _UIButtonBarButton:0x7f965fd15c10.trailing   (active)>",
//        "<NSLayoutConstraint:0x600001503ac0 'UINav_static_button_horiz_position' _UIModernBarButton:0x7f965fd1b500.leading == UILayoutGuide:0x600000f51b20'UIViewLayoutMarginsGuide'.leading   (active)>",
//        "<NSLayoutConstraint:0x600001503b10 'UINavItemContentGuide-leading' H:[_UIButtonBarButton:0x7f965fd15c10]-(0)-[UILayoutGuide:0x600000f51a40'UINavigationBarItemContentLayoutGuide']   (active)>",
//        "<NSLayoutConstraint:0x600001500f00 'UINavItemContentGuide-trailing' UILayoutGuide:0x600000f51a40'UINavigationBarItemContentLayoutGuide'.trailing == _UINavigationBarContentView:0x7f965fd12f80.trailing   (active)>",
//        "<NSLayoutConstraint:0x600001528230 'UIView-Encapsulated-Layout-Width' _UINavigationBarContentView:0x7f965fd12f80.width == 0   (active)>",
//        "<NSLayoutConstraint:0x6000015012c0 'UIView-leftMargin-guide-constraint' H:|-(0)-[UILayoutGuide:0x600000f51b20'UIViewLayoutMarginsGuide'](LTR)   (active, names: '|':_UINavigationBarContentView:0x7f965fd12f80 )>"
//    )
//
//    Will attempt to recover by breaking constraint
//    <NSLayoutConstraint:0x600001502d00 'BIB_Trailing_CB_Leading' H:[_UIModernBarButton:0x7f965fd1b500]-(6)-[_UIModernBarButton:0x7f965fd174f0'Emoji Art']   (active)>
//
//    Make a symbolic breakpoint at UIViewAlertForUnsatisfiableConstraints to catch this in the debugger.
//    The methods in the UIConstraintBasedLayoutDebugging category on UIView listed in <UIKitCore/UIView.h> may also be helpful.
//    Message from debugger: Terminated due to signal 9

//    func readyStore() -> EmojiArtDocumentStore {
//        let store = EmojiArtDocumentStore(named: "EmojiArt")
//        store.addDocument()
//        store.addDocument(named: "Hello World")
//        return store
//    }
    
}
