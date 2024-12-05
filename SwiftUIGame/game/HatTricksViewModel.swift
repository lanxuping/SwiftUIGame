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
        let rightIndex = Array(0..<levelModel.hatsCount).randomElement()!
        for i in Array(0..<levelModel.hatsCount) {
            let hat = HatTricksHatModel(id: i, showResult: false, result: rightIndex == i)
            if rightIndex == i {
                hasBallHat = hat
            }
            hatItems.append(hat)
        }
        ballState = .norml
    }
    var hasBallHat: HatTricksHatModel!
    @Published var levelModel: HatTricksLevelModel = .init()
    @Published var ballModel: HatTricksBallModel = .init()
    @Published var hatItems: [HatTricksHatModel] = []
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
        if let has = hatItems.firstIndex(where: { $0.id == hasBallHat.id }), let target = displayFrames[has] {
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
            print(index)
            if let has = hatItems.firstIndex(where: { $0.id == hasBallHat.id }) {
                hatItems[index].showResult = true
                hatItems[has].showResult = true
            }
            if hasBallHat == hatItems[index] {
                print("结果 对了")
            } else {
                print("结果 错了")
            }
        }
    }
    
    func resetBall() {
        hatItems = hatItems.map { item in
            var mutableItem = item
            mutableItem.showResult = false
            return mutableItem
        }
        ballModel.offsetX = 0
        ballModel.offsetY = 0
        ballModel.rotation = 0
        ballModel.scale = 1
    }
    
    func beginPlayingGame() {
        resetBall()
        withAnimation(.linear(duration: 1)) {
            landingBallToCap(index: hasBallHat.id)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.ballState = .play
        }
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
        let target = levelModel.animatedTiming + animatedTiming
        if target > 0.3 && target < 3 {
            levelModel.animatedTiming = target
        }
    }
    func changeGameLevel(movingCount: Int) {
        let target = levelModel.movingCount + movingCount
        if target > 0 && target < 50 {
            levelModel.movingCount = target
        }
    }
    func changeGameLevel(hatsCount: Int) {
        let target = levelModel.hatsCount + hatsCount
        if target > 1 && target < 7 {
            levelModel.hatsCount = target
            var items: [HatTricksHatModel] = []
            let rightIndex = Array(0..<levelModel.hatsCount).randomElement()!
            for i in Array(0..<levelModel.hatsCount) {
                let hat = HatTricksHatModel(id: i, showResult: false, result: rightIndex == i)
                if rightIndex == i {
                    hasBallHat = hat
                }
                items.append(hat)
            }
            hatItems = items
        }
    }
    func changeGameLevel(colums: Int) {
        let target = levelModel.colums + colums
        if target > 1 && target < 4 {
            levelModel.colums = target
        }
    }
    func geoWidth() -> CGFloat {
        print(CGFloat(levelModel.colums) * getCapItemWidth() + CGFloat(levelModel.colums) * getCapItemSpace())
        return CGFloat(levelModel.colums) * getCapItemWidth() + CGFloat(levelModel.colums) * getCapItemSpace()
    }
}


struct HatTricksLevelModel {
    var animatedTiming: Double = 0.3
    var movingCount: Int = 3
    var hatsCount: Int = 3
    var colums: Int = 2
}

struct HatTricksBallModel {
    var rotation: CGFloat = 0
    var scale: CGFloat = 1.0
    var offsetX: CGFloat = 0
    var offsetY: CGFloat = 0
}

struct HatTricksHatModel: Equatable {
    let id: Int
    var showResult: Bool
    var result: Bool
    static func == (lhs: HatTricksHatModel, rhs: HatTricksHatModel) -> Bool {
        return lhs.id == rhs.id
    }
}
