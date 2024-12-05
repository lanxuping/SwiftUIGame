//
//  EffectManager.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI
struct BallGeometryEffect: GeometryEffect {
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
//        print(scale, rotation, offsetX, offsetY)
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

struct HatTricksArcMove: GeometryEffect {
    var progress: CGFloat
    var height: CGFloat
    var isTopArc: Bool
    var point: (CGPoint, CGPoint)
    
    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        let distance = sqrt(pow(point.1.x-point.0.x,2) + pow(point.1.y-point.0.y,2))
        var x: CGFloat = point.0.x
        var y: CGFloat = point.0.y
        if distance != 0 {
            x = progress * (point.1.x-point.0.x) - height * progress * (progress-1) * (point.0.y-point.1.y)/distance
            y = progress * (point.1.y-point.0.y) - height * progress * (progress-1) * (point.1.x-point.0.x)/distance
        }
        let transform = CGAffineTransform(translationX: -x, y: -y)
//        print("自变量\(progress)\n两点转换【\(point) \(isTopArc)】\n 进度点x:\(x), y\(y) \n\n")
        return ProjectionTransform(transform)
    }
}
