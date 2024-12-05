//
//  GameContainerView.swift
//  Memorize
//
//  Created by lanxuping on 2024/12/4.
//

import SwiftUI

enum GameOverType {
    case none, success, failed
}
class VM: GameViewModelProtocol {
    var gameState: GameOverType
    var isStop: Bool
    init(gameState: GameOverType, isStop: Bool) {
        self.gameState = gameState
        self.isStop = isStop
    }
    func stopGame() { }
}

protocol GameViewModelProtocol: ObservableObject {
    var gameState: GameOverType { get set }
    var isStop: Bool { get set }
    func stopGame()
}

struct GameContainerView<Content: View, ViewModel: GameViewModelProtocol>: View {
    let didEnterBackgroundPublisher = NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
    
    @StateObject var viewModel: ViewModel
    let content: Content
    
    init(viewModel: ViewModel, @ViewBuilder content: () -> Content) {
        self._viewModel = StateObject(wrappedValue: viewModel)
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Image("位图").resizable().ignoresSafeArea()
            VStack(spacing: 0) {
                if viewModel.gameState != .none {
                    Color.red.ignoresSafeArea()
                } else {
                    controView
                    Spacer()
                    content
                        .frame(maxWidth: .infinity, maxHeight: KHEIGHT - KNavHeight - BOTTOM_HEIGHT - 110)
                        .background { Color.blue.opacity(0.2) }
                    Spacer()
                }
                nextLevView.opacity(viewModel.gameState != .none ? 1 : 0).padding(.bottom, 6)
                adView.padding(.bottom, 6)
            }
            stopListView.opacity(viewModel.isStop ? 1 : 0)
        }
        .onReceive(didEnterBackgroundPublisher) { _ in
            if viewModel.gameState == .none {
                viewModel.stopGame()
            }
        }
    }
}

extension GameContainerView {
    var controView: some View {
        Color.green.frame(height: 50)
    }
    var stopListView: some View {
        Color.green.ignoresSafeArea()
    }
    var nextLevView: some View {
        Color.green.frame(height: 50)
    }
    var adView: some View {
        Color.green.frame(height: 50)
    }
    var lottieView: some View {
        Color.green.ignoresSafeArea()
    }
}


struct Tools {
    static func currentWindow() -> UIWindow? {
        guard #available(iOS 13.0, *) else {
            if let appDelegate = UIApplication.shared.delegate,
               let window = appDelegate.window {
                return window
            }
        }
        guard let scene = UIApplication.shared.connectedScenes.first,
              let sceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = sceneDelegate.window else {
                  return UIApplication.shared.windows.last
              }
        return window
    }
}
//MARK: =================================================================================================================================================
let KSCREEN_BOUNDS = UIScreen.main.bounds
let KWIDTH = UIScreen.main.bounds.size.width
let KHEIGHT = UIScreen.main.bounds.size.height
var KNavHeight : Double  {
    var height = 0.0
    let insets = Tools.currentWindow()?.safeAreaInsets
    height = insets!.top > 0 ? 44.0 + insets!.top : 44.0
    return height
}
var KStatusBarHeight : CGFloat  {
    var height : CGFloat = 0.0
    let insets = Tools.currentWindow()?.safeAreaInsets
    height = insets?.top ?? 44.0
    return height
}
var KTabBarHeight : Double  {
    var height = 0.0
    let insets = Tools.currentWindow()?.safeAreaInsets
    let bottom = insets?.bottom ?? 34
    height = bottom > 0 ? 49.0 + bottom : 49.0;
    return height
}
var BOTTOM_HEIGHT : Double  {
    var height = 0.0
    let insets = Tools.currentWindow()?.safeAreaInsets
    let bottom = insets?.bottom ?? 34.0
    height = bottom;
    return height
}
