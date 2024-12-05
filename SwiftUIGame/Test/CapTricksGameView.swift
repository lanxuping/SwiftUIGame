//
//  CapTricksGameView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/3.
//

import SwiftUI

struct CapTrickersArcMove: GeometryEffect {
    var progress: CGFloat // 动画进度，范围从 0 到 1
    var height: CGFloat // 动画中元素的垂直移动高度
    var isTopArc: Bool // 布尔值，指示弧形是向上还是向下
    var point: (CGPoint, CGPoint)

    // 计算属性，允许动画系统根据 progress 的变化来更新视图
    var animatableData: CGFloat {
        get { return progress }
        set { progress = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        let newdistance = point.0.x - point.1.x
        let x = newdistance * progress
        let y = sin(progress * .pi) * height * (isTopArc ? -1 : 1)
        let transform = CGAffineTransform(translationX: x, y: y)
        print("自变量\(progress)\n两点转换【\(point)】\n 进度点x:\(x), y\(y) \n\n")
        return ProjectionTransform(transform)
    }
}


struct CapTricksGameView: View {
    @StateObject var viewModel: CapTricksViewModel = .init()

    var body: some View {
        VStack {
            ZStack {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: viewModel.getCapItemSpace()), count: viewModel.capsItems.count), spacing: 0) {
                    ForEach(viewModel.capsItems.indices, id: \.self) { index in
                        Rectangle()
                            .fill(.clear)
                            .frame(width: viewModel.getCapItemWidth(), height: viewModel.getCapItemHeight())
                            .overlay {
                                if viewModel.capsItems[index] == 1 {
                                    VStack {
                                        Spacer()
                                        Circle()
                                            .fill(.yellow)
                                    }
                                }
                            }
                    }
                }
                .frame(width: CGFloat(viewModel.capsItems.count) * viewModel.getCapItemWidth() + CGFloat(viewModel.capsItems.count - 1) * viewModel.getCapItemSpace())
                .opacity(viewModel.showBall ? 1 : 0)
                
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: viewModel.getCapItemSpace()), count: viewModel.capsItems.count), spacing: 0) {
                    ForEach(viewModel.capsItems.indices, id: \.self) { index in
                        GeometryReader { geometry in
                            if index < viewModel.capsItems.count {
                                let geoFrame = geometry.frame(in: .global)
                                
                                Image("帽子")
                                    .resizable()
                                    .frame(width: viewModel.getCapItemWidth(), height: viewModel.getCapItemHeight())
                                    .modifier(CapTrickersArcMove(
                                        progress: viewModel.getProgress(for: index),
                                        height: viewModel.getArcHeight(),
                                        isTopArc: viewModel.JudgmentIsPositiveDisplay(index: index),
                                        point: viewModel.calculateDistancePoint(for: index)
                                    ))
                                    .onAppear { viewModel.displayFrames[index] = geoFrame }
                                    .onChange(of: geoFrame) { newFrame in viewModel.displayFrames[index] = newFrame }
                                    .onTapGesture {
                                        print("\(viewModel.capsItems[index])")
                                    }
                                    .overlay {
                                        Text("\(viewModel.capsItems[index])\nx:\(Int(geoFrame.minX))\ny:\(Int(geoFrame.minY))\nw:\(Int(geoFrame.width))\nh:\(Int(geoFrame.height))").foregroundColor(.white)
                                    }
                            }
                        }
                        .frame(height: viewModel.getCapItemHeight())
                    }
                }
                .frame(width: CGFloat(viewModel.capsItems.count) * viewModel.getCapItemWidth() + CGFloat(viewModel.capsItems.count - 1) * viewModel.getCapItemSpace())
                .offset(y: viewModel.beginGame ? 0 : -60)
                .animation(.linear, value: viewModel.beginGame)
            }
            .padding()
            .background(Color.red)

            swapView
            gameButtomView
            timingView
            movingCoutView
            capsCountView
        }
    }
}

extension CapTricksGameView {
    var swapView: some View {
        Button("随机交换") {
            viewModel.swapRandomItems(count: viewModel.movingCount)
        }
        .disabled(!viewModel.beginGame)
    }
    
    var gameButtomView: some View {
        Button(viewModel.beginGame ? "游戏阶段" : "记忆阶段") {
            viewModel.beginGame.toggle()
            if !viewModel.beginGame {
                viewModel.showBall = true
            }
        }
    }
    
    var timingView: some View {
        HStack {
            Button {
                if viewModel.animatedTiming > 0.1 {
                    viewModel.animatedTiming -= 0.1
                }
            } label: {
                Image(systemName: "minus.circle")
            }
            .disabled(viewModel.animatedTiming <= 0.1)
            Text("动画时间\(viewModel.animatedTiming)")
            
            Button {
                if viewModel.animatedTiming < 2 {
                    viewModel.animatedTiming += 0.1
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            .disabled(viewModel.animatedTiming > 2)
        }
    }
    
    var movingCoutView: some View {
        HStack {
            Button {
                if viewModel.movingCount > 1 {
                    viewModel.movingCount -= 1
                }
            } label: {
                Image(systemName: "minus.circle")
            }
            .disabled(viewModel.movingCount <= 1)
            Text("移动次数\(viewModel.movingCount)")
            
            Button {
                if viewModel.movingCount < 9 {
                    viewModel.movingCount += 1
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            .disabled(viewModel.movingCount > 8)
        }
    }
    
    var capsCountView: some View {
        HStack {
            Button {
                if viewModel.capsCount > 3 {
                    viewModel.resetItems(-1)
                }
            } label: {
                Image(systemName: "minus.circle")
            }
            .disabled(viewModel.capsCount <= 3)
            Text("多少🎩\(viewModel.capsCount)")
            
            Button {
                if viewModel.capsCount < 7 {
                    viewModel.resetItems(1)
                }
            } label: {
                Image(systemName: "plus.circle")
            }
            .disabled(viewModel.capsCount > 6)
        }
    }
}

#Preview {
    CapTricksGameView()
}
