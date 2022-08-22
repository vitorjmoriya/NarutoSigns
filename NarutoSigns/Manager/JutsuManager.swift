//
//  JutsuManager.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 22/08/22.
//

class JutsuManager {
    var handSigns: [Sign]

    static let shared = JutsuManager()

    init() {
        self.handSigns = []
    }
}
