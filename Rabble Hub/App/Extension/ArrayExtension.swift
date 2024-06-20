//
//  ArrayExtension.swift
//  Rabble Hub
//
//  Created by aljon antiola on 6/20/24.
//

import Foundation

extension Array where Element == String {
    func indexOfIgnoringCase(_ searchString: String) -> Int? {
        return self.firstIndex { $0.caseInsensitiveCompare(searchString) == .orderedSame }
    }
}
