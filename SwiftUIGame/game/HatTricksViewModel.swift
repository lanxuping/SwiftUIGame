//
//  HatTricksViewModel.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import Foundation
import SwiftUI

enum BallShowStyle {
case norml, play, finish
}

class HatTricksViewModel: ObservableObject {
    init() {
        hatItems = Array(0..<levelModel.hatsCount)
        ballCapNumber = hatItems.randomElement()!
        ballState = .norml
    }
    var ballCapNumber: Int!
    @Published var levelModel: HatTricksLevelModel = .init()
    @Published var ballModel: HatTricksBallModel = .init()
    @Published var hatItems: [Int]!
    @Published var isAnimating = false
    @Published var ballState: BallShowStyle = .norml
    var displayFrames: [Int: CGRect] = [:]
    @Published var ballDisplayFrame: CGRect = .zero
    private var selectedIndices: (Int, Int)? = nil
    
    func getProgress(for index: Int) -> CGFloat {
        guard let selected = selectedIndices else { return 0 }
        if index == selected.0 || index == selected.1 {
            return isAnimating ? 1 : 0
        }
        return 0
    }

    func calculateDistancePoint(for index: Int) -> (CGPoint, CGPoint) {
        guard let selected = selectedIndices else { return (.zero, .zero) }
        if index == selected.0 {
            return (CGPoint(x: displayFrames[selected.1]!.minX, y: displayFrames[selected.1]!.minY), CGPoint(x: displayFrames[selected.0]!.minX, y: displayFrames[selected.0]!.minY))
        } else if index == selected.1 {
            return (CGPoint(x: displayFrames[selected.0]!.minX, y: displayFrames[selected.0]!.minY), CGPoint(x: displayFrames[selected.1]!.minX, y: displayFrames[selected.1]!.minY))
        }
        return (.zero, .zero)
    }

    func swapRandomItems(count: Int = 1) {
        if count < 1 {
            return
        }
        guard ballState == .play else { return }
        guard !isAnimating else { return }
        let firstIndex = Int.random(in: 0..<hatItems.count)
        var secondIndex = Int.random(in: 0..<hatItems.count)
        while secondIndex == firstIndex {
            secondIndex = Int.random(in: 0..<hatItems.count)
        }
        selectedIndices = (firstIndex, secondIndex)
        withAnimation(.easeInOut(duration: levelModel.animatedTiming)) {
            isAnimating = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + levelModel.animatedTiming) {
            self.hatItems.swapAt(firstIndex, secondIndex)
            self.selectedIndices = nil
            self.isAnimating = false
            self.swapRandomItems(count: count - 1)
        }
    }
    
    func judgmentIsPositiveDisplay(index: Int) -> Bool {
        return selectedIndices?.0 == index
    }
    
    func landingBallToCap(index: Int) {
        if let has = hatItems.firstIndex(of: ballCapNumber), let target = displayFrames[has] {
            ballModel.offsetX = target.minX - ballDisplayFrame.minX + 35 * 0.78
            ballModel.offsetY = target.minY - ballDisplayFrame.minY
            ballModel.rotation += 360
            ballModel.scale = 0.78
        }
    }
    
    func clickHatToCheckBallResult(index: Int) {
        if ballState == .play {
            ballState = .finish
            landingBallToCap(index: index)
            withAnimation(.linear(duration: 0.3)) {
                self.ballModel.offsetY -= 60
            }
            if ballCapNumber == hatItems[index] {
                print("结果 对了")
            } else {
                print("结果 错了")
            }
        }
    }
    
    func resetBall() {
        ballModel.offsetX = 0
        ballModel.offsetY = 0
        ballModel.rotation = 0
        ballModel.scale = 1
    }
}

extension HatTricksViewModel {
    func getCapItemWidth() -> CGFloat {
        return 92
    }
    func getCapItemHeight() -> CGFloat {
        return 119
    }
    func getCapItemSpace() -> CGFloat {
        return 20
    }
}

extension HatTricksViewModel {
    func changeGameLevel(animatedTiming: Double) {
        levelModel.animatedTiming += animatedTiming
    }
    func changeGameLevel(movingCount: Int) {
        levelModel.movingCount += movingCount
    }
    func changeGameLevel(hatsCount: Int) {
        levelModel.hatsCount += hatsCount
        hatItems = Array(0..<levelModel.hatsCount)
    }
    func geoWidth() -> CGFloat {
        print(CGFloat(levelModel.colums) * getCapItemWidth() + CGFloat(levelModel.colums) * getCapItemSpace())
        return CGFloat(levelModel.colums) * getCapItemWidth() + CGFloat(levelModel.colums) * getCapItemSpace()
    }
    func changeGameLevel(colums: Int) {
        levelModel.colums += colums
    }
}


struct HatTricksLevelModel {
    var animatedTiming: Double = 0.3
    var movingCount: Int = 1
    var hatsCount: Int = 3
    var colums: Int = 2
}

struct HatTricksBallModel {
    var rotation: CGFloat = 0
    var scale: CGFloat = 1.0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
}
