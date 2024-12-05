//
//  HatTricksGameView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI

struct HatTricksGameView: View {
    @StateObject var viewModel: HatTricksViewModel = .init()

    var body: some View {
        ZStack {
            VStack(spacing: 60) {
                ballView
                capsView
                Text("").frame(height: 104)
            }
            .onAppear(perform: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.beginPlayingGame()
                }
            })
            HatTricksDebugView()
        }
        .environmentObject(viewModel)
    }
    
    var ballView: some View {
        GeometryReader { geometry in
            let geoFrame = geometry.frame(in: .global)
            Image("礼盒").resizable()
                .onAppear { viewModel.ballDisplayFrame = geoFrame }
                .onChange(of: geoFrame) { newFrame in viewModel.ballDisplayFrame = newFrame }
                .modifier(BallGeometryEffect(scale: viewModel.ballModel.scale,
                                             rotation: viewModel.ballModel.rotation,
                                             offsetX: viewModel.ballModel.offsetX,
                                             offsetY: viewModel.ballModel.offsetY))
                .overlay {
                    Text("x:\(Int(viewModel.ballDisplayFrame.minX))\ny:\(Int(viewModel.ballDisplayFrame.minY))")
                }
                .background(Color.yellow)
                .opacity(viewModel.ballState == .play ? 0 : 1)
        }
        .frame(width: 64, height: 64)
    }
    
    var capsView: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.fixed(viewModel.getCapItemWidth()), spacing: viewModel.getCapItemSpace()), count: viewModel.levelModel.colums), spacing: 96) {
            ForEach(viewModel.hatItems.indices, id: \.self) { index in
                GeometryReader { geometry in
                    if index < viewModel.hatItems.count {
                        let geoFrame = geometry.frame(in: .global)
                        
                        Image("帽子").resizable()
                            .onAppear { viewModel.displayFrames[index] = geoFrame }
                            .onChange(of: geoFrame) { newFrame in viewModel.displayFrames[index] = newFrame }
                            .modifier(HatTricksArcMove(progress: viewModel.getProgress(for: index), height: 200, isTopArc: viewModel.judgmentIsPositiveDisplay(index: index), point: viewModel.calculateDistancePoint(for: index)))
                            .onTapGesture {
                                //print("\(viewModel.hatItems[index])   \(geoFrame)")
                                viewModel.clickHatToCheckBallResult(index: index)
                            }
                            .overlay {
                                Text("\(viewModel.hatItems[index].id)\n\(viewModel.hatItems[index].showResult) [\(viewModel.hatItems[index].result)]\nx:\(Int(geoFrame.minX))\ny:\(Int(geoFrame.minY))").foregroundColor(.black)
                                    .font(.system(size: 12))
                            }
                            .overlay(alignment: .bottomTrailing) {
                                Image(viewModel.hatItems[index].result ? "正确" : "错误")
                                    .frame(width: 32, height: 32)
                                    .opacity(viewModel.hatItems[index].showResult ? 1 : 0)
                                    .animation(.linear(duration: 0.3), value: viewModel.hatItems[index].showResult)
                            }
                    }
                }
                .frame(height: viewModel.getCapItemHeight())
            }
        }
    }
}

#Preview {
    HatTricksGameView()
}
