//
//  ChildView.swift
//  WhimsyLand
//
//  Created by KIM, SoonJoo on 7/13/25.
//

import SwiftUI

struct ChildView: View {
    var id: String
    var title: String
    var color: Color
// Assets에 image 파일이 없으므로 오류를 피하기 위해 주석 처리. image 파일 추가 후 주석 삭제.
//    var image: String
    
//    @State private var shouldMove = false
    @State private var position = CGPoint(x: 800, y: 400)
    @State private var scale = 1.0
    
    @Environment(\.dismissWindow) private var dismissWindow

    var body: some View {
        VStack(alignment: .center, spacing: 20) {
//            Image(image)
//                .resizable()
//                .frame(width: 100, height: 100)
//                .foregroundColor(.yellow)
            Text("Hello, \(title)!")
            Button("Close") {
                dismissWindow(id: self.id)
            }
        }
        .padding()
        .frame(width: 200, height: 300, alignment: Alignment.center)
        .background(color)
        .position(position)
        .scaleEffect(CGSize(width: scale, height: scale))
//        .gesture(
//            LongPressGesture(minimumDuration: 0.7)
//                .onEnded { _ in
//                    print("long press ended")
//                    shouldMove = true
//                    withAnimation{
//                        scale = 1.1
//                    }
//                }
//                .simultaneously(
//                    with: DragGesture()
//                        .onChanged { gesture in
//                            if shouldMove {
//                                print("drag starts on ", gesture.location)
//                                position = gesture.location
//                            } else {
//                                print("not able to move")
//                            }
//                        }
//                        .onEnded { gesture in
//                            print("drag endes")
//                            shouldMove = false
//                            withAnimation{
//                                scale = 1.0
//                            }
//                        }
//                )
//        )
    }
}

//#Preview {
//    ChildView()
//}
