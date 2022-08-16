//
//  HandsignManager.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 16/08/22.
//

class HandsignManager {
    var handSigns: [String]

    var onDetectedHandSign: ((String) -> Void)?

    static let shared = HandsignManager()

    init() {
        self.handSigns = []
    }

    func addHandSign(sign: String) {
        if handSigns.count == 4 {
            getDetectedHandSign()
            handSigns.removeAll()
        }
        handSigns.append(sign)
    }

    private func getDetectedHandSign() {
        var dict: [String: Int] = [:]

        guard var mostDetectedSign = handSigns.first else {
            // TODO: Log error here
            print("Error")
            return
        }

        handSigns.forEach { sign in
            dict[sign, default: 0] += 1
            
            if dict[sign, default: 0] > dict[mostDetectedSign, default: 0] {
                mostDetectedSign = sign
            }
        }

        onDetectedHandSign?(mostDetectedSign)
    }
}
