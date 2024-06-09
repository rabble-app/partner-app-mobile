//
//  StringExtension.swift
//  Rabble Hub
//
//  Created by Franz Henri De Guzman on 6/5/24.
//

import Foundation

extension String {
    func firstAndLastFour() -> String {
        guard self.count > 8 else { return self }
        let start = self.prefix(4)
        let end = self.suffix(4)
        return "\(start)...\(end)"
    }
    
    func toInt() -> Int? {
        return Int(self)
    }
}
