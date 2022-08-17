//
//  HandsignManager.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 16/08/22.
//

class HandsignManager {
    var handSigns: [Sign]

    var onDetectedHandSign: ((Sign) -> Void)?

    private var isBoarSign: Bool = false

    static let shared = HandsignManager()

    init() {
        self.handSigns = []
    }

    func addHandSign(sign: NarutoSignsOutput) {
        // This sign is the most difficult to execute & to detect, so we are giving a little help
        if let signBoar = sign.labelProbabilities["boar"] {
            if signBoar > 0.15 {
                isBoarSign = true
            }
        }

        let signModel = Sign.getSignFromString(string: sign.label)

        if handSigns.count == 4 {
            getDetectedHandSign()
            handSigns.removeAll()
            isBoarSign = false
        }
        handSigns.append(signModel)
    }

    private func getDetectedHandSign() {
        var dict: [Sign: Int] = [:]

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

        if isBoarSign {
            onDetectedHandSign?(.boar)
        } else {
            onDetectedHandSign?(mostDetectedSign)
        }
    }
}
