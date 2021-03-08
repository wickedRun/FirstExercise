//
//  Array+Only.swift
//  Memorize
//
//  Created by wickedRun on 2021/02/10.
//

import Foundation

extension Array {
    var only: Element? {
        count == 1 ? first : nil
    }
}
