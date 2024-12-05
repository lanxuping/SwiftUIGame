//
//  DragBallView.swift
//  SwiftUIGame
//
//  Created by lanxuping on 2024/12/5.
//

import SwiftUI

struct DragBallView: View {
    @GestureState var position: CGPoint = .zero
    var body: some View {
        VStack {
            Circle()
                .fill(.orange)
                .frame(width: 30, height: 50)
                .offset(x: position.x, y: position.y)
                .transaction {
                    if $0.isContinuous {
                        $0.animation = nil // 拖动时，不设置时序曲线函数
                    } else {
                        $0.animation = .easeInOut(duration: 1)
                    }
                }
                .gesture(
                    DragGesture()
                        .updating($position, body: { current, state, transaction in
                            state = .init(x: current.translation.width, y: current.translation.height)
                            transaction.isContinuous = true // 拖动时，设置标识
                        })
                )
        }
        .frame(width: 400, height: 500)
    }
}

import enum Accelerate.vDSP

struct AnimatableVector: VectorArithmetic {
    static var zero = AnimatableVector(values: [0.0])

    static func + (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.add(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func += (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.add(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    static func - (lhs: AnimatableVector, rhs: AnimatableVector) -> AnimatableVector {
        let count = min(lhs.values.count, rhs.values.count)
        return AnimatableVector(values: vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count]))
    }

    static func -= (lhs: inout AnimatableVector, rhs: AnimatableVector) {
        let count = min(lhs.values.count, rhs.values.count)
        vDSP.subtract(lhs.values[0..<count], rhs.values[0..<count], result: &lhs.values[0..<count])
    }

    var values: [Double]

    mutating func scale(by rhs: Double) {
        values = vDSP.multiply(rhs, values)
    }

    var magnitudeSquared: Double {
        vDSP.sum(vDSP.multiply(values, values))
    }
}

struct LineChart: Shape {
    var vector: AnimatableVector

    var animatableData: AnimatableVector {
        get { vector }
        set { vector = newValue }
    }

    func path(in rect: CGRect) -> Path {
        Path { path in
            let xStep = rect.width / CGFloat(vector.values.count)
            var currentX: CGFloat = xStep
            path.move(to: .zero)

            vector.values.forEach {
                path.addLine(to: CGPoint(x: currentX, y: CGFloat($0)))
                currentX += xStep
            }
        }
    }
}

struct RootView: View {
    @State private var vector: AnimatableVector = .zero

    var body: some View {
        LineChart(vector: vector)
            .stroke(Color.red)
//            .animation(Animation.default.repeatForever())
            .animation(.linear(duration: 2), value: vector)
            .onAppear {
                self.vector = AnimatableVector(values: [50, 100, 75, 0])
            }
    }
}

#Preview {
    RootView()
}
