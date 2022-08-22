//
//  NarutoMLModel.swift
//  NarutoSigns
//
//  Created by Vitor Moriya on 16/08/22.
//

struct NarutoMLModel {
    static let shared = NarutoMLModel()

    let model: NarutoSigns

    init() {
        do {
            self.model = try NarutoSigns(configuration: .init())
        }
        catch {
            fatalError(error.localizedDescription)
        }
    }
}
