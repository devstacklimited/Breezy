//
//  Date+Extensions.swift
//  Breezy
//
//  Created by Mian Usama on 14/10/2025.
//

import Foundation

extension Date {
    func hourString() -> String {
        let df = DateFormatter()
        df.dateFormat = "ha" /// e.g., 4PM
        return df.string(from: self)
    }
    func weekdayString() -> String {
        let df = DateFormatter()
        df.dateFormat = "EEE" /// Mon, Tue
        return df.string(from: self)
    }
}
