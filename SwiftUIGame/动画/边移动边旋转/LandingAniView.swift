//
//  LandingAniView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI

struct VectorPoint: VectorArithmetic {
    var point: CGPoint

    // MARK: - VectorArithmetic Protocol Requirements

    static var zero: VectorPoint {
        return VectorPoint(point: .zero)
    }

    var magnitudeSquared: Double {
        return Double(point.x * point.x + point.y * point.y)
    }

    mutating func scale(by rhs: Double) {
        point.x *= rhs
        point.y *= rhs
    }

    static func + (lhs: VectorPoint, rhs: VectorPoint) -> VectorPoint {
        return VectorPoint(point: CGPoint(x: lhs.point.x + rhs.point.x, y: lhs.point.y + rhs.point.y))
    }

    static func - (lhs: VectorPoint, rhs: VectorPoint) -> VectorPoint {
        return VectorPoint(point: CGPoint(x: lhs.point.x - rhs.point.x, y: lhs.point.y - rhs.point.y))
    }

    static func += (lhs: inout VectorPoint, rhs: VectorPoint) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout VectorPoint, rhs: VectorPoint) {
        lhs = lhs - rhs
    }

    static func * (lhs: VectorPoint, rhs: Double) -> VectorPoint {
        return VectorPoint(point: CGPoint(x: lhs.point.x * rhs, y: lhs.point.y * rhs))
    }

    static func / (lhs: VectorPoint, rhs: Double) -> VectorPoint {
        return VectorPoint(point: CGPoint(x: lhs.point.x / rhs, y: lhs.point.y / rhs))
    }

    static func *= (lhs: inout VectorPoint, rhs: Double) {
        lhs = lhs * rhs
    }

    static func /= (lhs: inout VectorPoint, rhs: Double) {
        lhs = lhs / rhs
    }
}

struct SkewedOffsetdd: GeometryEffect {
    var scale: CGFloat
    var rotation: CGFloat
    var point: VectorPoint

    var animatableData: AnimatablePair<CGFloat, AnimatablePair<CGFloat, VectorPoint>> {
        get {
            AnimatablePair(scale, AnimatablePair(rotation, point))
        }
        set {
            scale = newValue.first
            rotation = newValue.second.first
            point = newValue.second.second
        }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        print(scale, rotation, point)
        let centerX = size.width / 2
        let centerY = size.height / 2
        let translationToOrigin = CGAffineTransform(translationX: -centerX, y: -centerY)
        let rotationTransform = CGAffineTransform(rotationAngle: rotation * .pi / 180)
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let translationBack = CGAffineTransform(translationX: centerX, y: centerY)
        let translationTransform = CGAffineTransform(translationX: point.point.x, y: point.point.y)
        
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
    @State private var point: CGPoint = .zero

    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.blue.ignoresSafeArea()
            Image("礼盒")
                .frame(width: 100, height: 100)
                .modifier(SkewedOffsetdd(scale: scale, rotation: rotation, point: VectorPoint(point: point)))
                .onTapGesture {
                    withAnimation(Animation.linear(duration: 2)) {
                        rotation -= 720
                        scale -= 0.22
                        point.x += 100
                        point.y += 150
                    }
                }
            HStack {
                Button {
                    withAnimation(.linear(duration: 1.5)) {
                        rotation -= 720
                        scale -= 0.22
                        point.x += 50
                        point.y += 150
                    }
                } label: {
                    Text("降低")
                }
                Button {
                    withAnimation(.linear(duration: 1.5)) {
                        rotation = 0
                        scale = 1
                        point.x = 0
                        point.y = 0
                    }
                } label: {
                    Text("上升")
                }
            }
            .background(Color.red)
        }
    }
}
