//
//  ImagePicker.swift
//  EmojiArt
//
//  Created by wickedRun on 2021/05/05.
//

import SwiftUI
import UIKit

// 이건 컨트롤러인 이유는 사진라이브러리에서 사진을 고르기 때문에 컨트롤러로 하는 것 같다.
// 다른 이유가 있을 수 있기 때문에 찾아보기를.
typealias PickedImageHandler = (UIImage?) -> Void    // 타입 별명 이걸로 바꿈.
struct ImagePicker: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var handlePickedImage: PickedImageHandler
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
//        picker.sourceType = .photoLibrary   // 이 부분을 .camera로 바꾼다면 카메라 사용가능 인데 둘다 사용하게 바꾼다.
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var handlePickedImage: PickedImageHandler
        
        init(handlePickedImage: @escaping PickedImageHandler) {
            self.handlePickedImage = handlePickedImage
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            handlePickedImage(info[.originalImage] as? UIImage)
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
    }
}

// 기본 구성
//struct ImagePicker: UIViewControllerRepresentable {
//    func makeUIViewController(context: Context) -> some UIViewController {
//        let picker = UIImagePickerController()
//
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
//
//    }
//
//    func makeCoordinator() -> Coordinator {
//        <#code#>
//    }
//
//    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    }
//}
