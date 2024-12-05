//
//  HatTricksDebugView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI
func formatNumberToString(_ number: Double) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .decimal
    formatter.minimumFractionDigits = 1
    formatter.maximumFractionDigits = 1
    
    if let formattedString = formatter.string(from: NSNumber(value: number)) {
        return formattedString
    } else {
        return "\(number)" // 如果格式化失败，返回原始字符串
    }
}
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
            Text("ball offset 【x:\(Int(viewModel.ballModel.offsetX)) y:\(Int(viewModel.ballModel.offsetY))】")
            HStack {
                Button("exchange\n🔁") {
                    viewModel.swapRandomItems(count: viewModel.levelModel.movingCount)
                }
                .padding()
                .disabled(viewModel.ballState != .play)

                OperationView(title: "⌚️", count: "\(formatNumberToString(viewModel.levelModel.animatedTiming))") {
                    viewModel.changeGameLevel(animatedTiming: -0.1)
                } onPlus: {
                    viewModel.changeGameLevel(animatedTiming: 0.1)
                }

                OperationView(title: "🏃🏻", count: "\(viewModel.levelModel.movingCount)") {
                    viewModel.changeGameLevel(movingCount: -1)
                } onPlus: {
                    viewModel.changeGameLevel(movingCount: 1)
                }
                
                OperationView(title: "🎩", count: "\(viewModel.levelModel.hatsCount)") {
                    viewModel.changeGameLevel(hatsCount: -1)
                } onPlus: {
                    viewModel.changeGameLevel(hatsCount: 1)
                }
                
                OperationView(title: "🀜", count: "\(viewModel.levelModel.colums)") {
                    viewModel.changeGameLevel(colums: -1)
                } onPlus: {
                    viewModel.changeGameLevel(colums: 1)
                }

                Button("Begin\n⏯️") {
                    viewModel.beginPlayingGame()
                }
                .padding()
                .disabled(viewModel.ballState == .play)
                
            }
        }
    }
}

struct OperationView: View {
    var title: String
    var count: String
    var onMinus: () -> Void
    var onPlus: () -> Void
    var body: some View {
        VStack {
            Text(title)
            Text(count)
            HStack {
                Button(action: onMinus) {
                    Image(systemName: "minus.circle")
                }
                Button(action: onPlus) {
                    Image(systemName: "plus.circle")
                }
            }
        }
    }
}
