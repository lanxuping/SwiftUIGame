//
//  CapTricksViewModel.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/3.
//

import SwiftUI

class CapTricksViewModel: ObservableObject {
    // 帽子视图容器
    @Published var capsCount: Int = 3
    @Published var capsItems: [Int] = Array(1...3)

    // 存储每个视图的 frame
    var displayFrames: [Int: CGRect] = [:]
    // 声明一个状态变量 isAnimating，指示动画是否正在进行
    @Published var isAnimating = false
    // 声明一个可选的元组状态变量 selectedIndices，用于存储被选中的两个索引
    private var selectedIndices: (Int, Int)? = nil
    private var arcHeight: CGFloat = 90
    private var itemWidth: CGFloat = 50
    private var itemHeight: CGFloat = 150
    private var itemSpace: CGFloat = 15
    // 是否开始游戏
    @Published var beginGame: Bool = false
    @Published var showBall: Bool = true

    // 每次交换所需时间
    @Published var animatedTiming: Double = 0.3
    // 点击开始游戏交换几次帽子视图
    @Published var movingCount: Int = 1

    // 根据索引返回动画进度
    func getProgress(for index: Int) -> CGFloat {
        guard let selected = selectedIndices else { return 0 }
        //如果当前索引是选中的索引之一
        if index == selected.0 || index == selected.1 {
            //如果正在动画中，返回 1；否则返回 0
            return isAnimating ? 1 : 0
        }
        return 0
    }
    // 根据索引返回要进行移动的view的point
    func calculateDistancePoint(for index: Int) -> (CGPoint, CGPoint) {
        guard let selected = selectedIndices else { return (.zero, .zero) }
        if index == selected.0 {
            return (CGPoint(x: displayFrames[selected.1]!.minX, y: displayFrames[selected.1]!.minY), CGPoint(x: displayFrames[selected.0]!.minX, y: displayFrames[selected.0]!.minY))
        } else if index == selected.1 {
            return (CGPoint(x: displayFrames[selected.0]!.minX, y: displayFrames[selected.0]!.minY), CGPoint(x: displayFrames[selected.1]!.minX, y: displayFrames[selected.1]!.minY))
        }
        return (.zero, .zero)
    }

    // 用于随机交换数组中的两个元素
    func swapRandomItems(count: Int = 1) {
        if count < 1 {
            return
        }
        showBall = false
        guard !isAnimating else { return }// 如果正在动画中，返回，不执行后续代码
        // 随机选择第一个/第二个索引 确保第二个索引与第一个索引不同
        let firstIndex = Int.random(in: 0..<capsItems.count)
        var secondIndex = Int.random(in: 0..<capsItems.count)
        while secondIndex == firstIndex {
            secondIndex = Int.random(in: 0..<capsItems.count)
        }
        // 将选中的索引存储在 selectedIndices 中
        selectedIndices = (firstIndex, secondIndex)
        
        // 设置动画状态为 true
        withAnimation(.easeInOut(duration: animatedTiming)) {
            isAnimating = true
        }
        
        // 动画完成后更新数组
        DispatchQueue.main.asyncAfter(deadline: .now() + animatedTiming) {
            // 先更新数组交换数组中两个元素的位置
            self.capsItems.swapAt(firstIndex, secondIndex)
            // 然后重置状态重置选中的索引
            self.selectedIndices = nil
            self.isAnimating = false
            self.swapRandomItems(count: count - 1)
            if count < 1 {
                self.showBall = true
            }
        }
    }
    
    /// 判断是否是顶部左顶部显示（要交换的两个view一上一下）
    func JudgmentIsPositiveDisplay(index: Int) -> Bool {
        return selectedIndices?.0 == index
    }
    /// 获取弧线的高度
    func getArcHeight() -> CGFloat {
        return arcHeight
    }
    // 帽子视图的宽度
    func getCapItemWidth() -> CGFloat {
        return itemWidth
    }
    // 帽子视图的高度（与geometry的高度要保持契合）
    func getCapItemHeight() -> CGFloat {
        return itemHeight
    }
    // 帽子视图之间的间隔
    func getCapItemSpace() -> CGFloat {
        return itemSpace
    }
    
    func resetItems(_ count: Int) {
        capsCount += count
        capsItems = Array(1...capsCount)
    }
}
