//
//  HandsignManager.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 16/08/22.
//

class HandsignManager {
    var handSigns: [Sign]

    var onHandSign: ((Sign, Bool) -> Void)?

    var onDetectedHandSign: ((Sign) -> Void)?

    static let shared = HandsignManager()

    init() {
        self.handSigns = []
    }

    func addHandSign(sign: NarutoSignsOutput) {
        var signModel: Sign?

        // This sign is the most difficult to execute & to detect, so we are giving a little help
        if let signBoar = sign.labelProbabilities["boar"],
           signBoar > 0.15 {
            signModel = .boar
        } else {
            signModel = Sign.getSignFromString(string: sign.label)
        }

        if let signModel = signModel {
            handSigns.append(signModel)
            
            if handSigns.allSatisfy({ $0 == signModel }) {
                onHandSign?(signModel, true)
                if handSigns.count == 4 {
                    onDetectedHandSign?(signModel)
                    handSigns.removeAll()
                }
            } else {
                handSigns.removeAll()
                onHandSign?(signModel, false)
            }
        }
    }
}
