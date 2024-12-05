//
//  HatTricksDebugView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI
struct HatTricksDebugView: View {
    @EnvironmentObject var viewModel: HatTricksViewModel
    var body: some View {
        VStack {
            Spacer()
            debugChangeView
        }
    }
}
extension HatTricksDebugView {
    @ViewBuilder
    var debugChangeView: some View {
        VStack(spacing: 10) {
            swapView
            timingView
            movingCoutView
            capsCountView
            columsCountView
            ballMoveView
            beginGame
        }
    }
    var beginGame: some View {
        Button("开始游戏") {
            viewModel.resetBall()
            withAnimation(.linear(duration: 1)) {
                viewModel.landingBallToCap(index: viewModel.ballCapNumber)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                viewModel.ballState = .play
            }
        }
    }
    var swapView: some View {
        Button("随机交换") {
            viewModel.swapRandomItems(count: viewModel.levelModel.movingCount)
        }
        .disabled(viewModel.ballState != .play)
    }
    var timingView: some View {
        HStack {
            Button {
                viewModel.changeGameLevel(animatedTiming: -0.1)
            } label: {
                Image(systemName: "minus.circle")
            }
            Text("动画时间\(viewModel.levelModel.animatedTiming)")
            Button {
                viewModel.changeGameLevel(animatedTiming: 0.1)
            } label: {
                Image(systemName: "plus.circle")
            }
        }
    }
    
    var movingCoutView: some View {
        HStack {
            Button {
                viewModel.changeGameLevel(movingCount: -1)
            } label: {
                Image(systemName: "minus.circle")
            }
            Text("移动次数\(viewModel.levelModel.movingCount)")
            Button {
                viewModel.changeGameLevel(movingCount: 1)
            } label: {
                Image(systemName: "plus.circle")
            }
        }
    }
    
    var capsCountView: some View {
        HStack {
            Button {
                viewModel.changeGameLevel(hatsCount: -1)
            } label: {
                Image(systemName: "minus.circle")
            }
            Text("多少🎩\(viewModel.levelModel.hatsCount)")
            Button {
                viewModel.changeGameLevel(hatsCount: 1)
            } label: {
                Image(systemName: "plus.circle")
            }
        }
    }
    
    var columsCountView: some View {
        HStack {
            Button {
                viewModel.changeGameLevel(colums: -1)
            } label: {
                Image(systemName: "minus.circle")
            }
            Text("每行多少\(viewModel.levelModel.colums)")
            Button {
                viewModel.changeGameLevel(colums: 1)
            } label: {
                Image(systemName: "plus.circle")
            }
        }
    }
    
    var ballMoveView: some View {
        HStack {
            Button {
                withAnimation(.linear(duration: 1)) {
                    viewModel.resetBall()
                }
            } label: {
                Text("Reset Ball (\(viewModel.ballCapNumber))  \nx:\(Int(viewModel.ballModel.offsetX)) y:\(Int(viewModel.ballModel.offsetY)) ")
            }
        }
    }
}
