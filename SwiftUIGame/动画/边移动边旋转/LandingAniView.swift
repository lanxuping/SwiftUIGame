//
//  LandingAniView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI

struct SkewedOffsetdd: GeometryEffect {
    var scale: CGFloat
    var rotation: CGFloat
    var offsetX: CGFloat
    var offsetY: CGFloat

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, AnimatablePair<CGFloat, CGFloat>>> {
        get {
            AnimatablePair(scale, AnimatablePair(rotation, AnimatablePair(offsetX, offsetY)))
        }
        set {
            scale = newValue.first
            rotation = newValue.second.first
            offsetX = newValue.second.second.first
            offsetY = newValue.second.second.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        print(scale, rotation, offsetX, offsetY)
        let centerX = size.width / 2
        let centerY = size.height / 2
        let translationToOrigin = CGAffineTransform(translationX: -centerX, y: -centerY)
        let rotationTransform = CGAffineTransform(rotationAngle: rotation * .pi / 180)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let translationBack = CGAffineTransform(translationX: centerX, y: centerY)
        let translationTransform = CGAffineTransform(translationX: offsetX, y: offsetY)
        
        let combinedTransform = translationToOrigin
            .concatenating(rotationTransform)
            .concatenating(scaleTransform)
            .concatenating(translationBack)
            .concatenating(translationTransform)
        return ProjectionTransform(combinedTransform)
    }
}

struct LandingAniView: View {
    @State private var rotation: CGFloat = 0 // 旋转角度
    @State private var scale: CGFloat = 1.0 // 缩放因子
    @State private var offsetX: CGFloat = 0 // 位移距离
    @State private var offsetY: CGFloat = 1.0 // 透明度

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.blue.ignoresSafeArea()
            Image("礼盒")
                .frame(width: 100, height: 100)
                .modifier(SkewedOffsetdd(scale: scale, rotation: rotation, offsetX: offsetX, offsetY: offsetY))
                .onTapGesture {
                    withAnimation(Animation.linear(duration: 2)) {
                        rotation -= 720
                        scale -= 0.22
                        offsetX += 100
                        offsetY += 150
                    }
                }
            HStack {
                Button {
                    withAnimation(.linear(duration: 1.5)) {
                        rotation -= 720
                        scale -= 0.22
                        offsetX += 50
                        offsetY += 150
                    }
                } label: {
                    Text("降低")
                }
                Button {
                    withAnimation(.linear(duration: 1.5)) {
                        rotation = 0
                        scale = 1
                        offsetX = 0
                        offsetY = 0
                    }
                } label: {
                    Text("上升")
                }
            }
            .background(Color.red)
        }
    }
}
