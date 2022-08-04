//
//  SceneDelegate.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 04/08/22.
//

import UIKit
import os

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else {
            os_log("SceneDelegate.scene(_:willConnectTo:options) ignored (no UIWindowScene)")
            return
        }

        window = UIWindow(windowScene: windowScene)
        window?.makeKeyAndVisible()

        window?.rootViewController = MainController()
    }
}
