//
//  SwiftUIGameApp.swift
//  SwiftUIGame
//
//  Created by lanxuping on 2024/12/5.
//

import SwiftUI

@main
struct SwiftUIGameApp: App {
    var body: some Scene {
        WindowGroup {
            GameContainerView(viewModel: VM(gameState: .none, isStop: false)) {
                HatTricksGameView()
            }
//            LandingAniView()
//            AnimationDataMonitorGameContentView()
        }
    }
}
