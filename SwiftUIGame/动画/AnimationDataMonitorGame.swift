//
//  AnimationDataMonitorGame.swift
//  SwiftUIGame
//
//  Created by lanxuping on 2024/12/5.
//

import SwiftUI

struct AnimationDataMonitorGame: View, Animatable {
    var number: Double
    var offser: Double
    
    //当需要传递更多的参数时，可嵌套使用 AnimatablePair 类型，如：
    //AnimatablePair<CGFloat, AnimatablePair<Float, AnimatablePair<Double, CGFloat>>>
    //newValue.second.second.first.
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(number, offser) }
        set {
            number = newValue.first
            offser = newValue.second
        }
    }
    var body: some View {
        Text("\(number) \(offser)")
    }
}

struct AnimationDataMonitorGameContentView: View {
    @State var ani: Bool = false
    var body: some View {
        AnimationDataMonitorGame(number: ani ? 1 : 0, offser: ani ? 100 : 0)
            .animation(.linear(duration: 2), value: ani)
        Button {
            ani.toggle()
        } label: {
            Text("click me")
        }
    }
}

#Preview(body: {
    AnimationDataMonitorGameContentView()
})
