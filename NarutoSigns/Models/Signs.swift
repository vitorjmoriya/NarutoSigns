//
//  Signs.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 16/08/22.
//

enum Sign: CaseIterable {
    case bird
    case rat
    case snake
    case ox
    case dog
    case boar
    case horse
    case dragon
    case hare
    case tiger
    case monkey
    case ram

    static func getSignFromString(string: String) -> Sign {
        let sign = Sign.allCases.first(where: { sign in
            sign.rawValue == string
        })

        guard let sign = sign else {
            // TODO: Log error here, IMO this shouldn't happen at all
            return .bird
        }

        return sign
    }

    var rawValue: String {
        switch self {
        case .bird:
            return "bird"
        case .rat:
            return "rat"
        case .snake:
            return "snake"
        case .ox:
            return "ox"
        case .dog:
            return "dog"
        case .boar:
            return "boar"
        case .horse:
            return "horse"
        case .dragon:
            return "dragon"
        case .hare:
            return "hare"
        case .tiger:
            return "tiger"
        case .monkey:
            return "monkey"
        case .ram:
            return "ram"
        }
    }
}
