//
//  DateFormatter.swift
//  PhotoBurst
//
//  Created by Ryan Schefske on 1/1/20.
//  Copyright © 2020 Ryan Schefske. All rights reserved.
//

import UIKit

class FormatDate {
    func formatDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        return dateFormatter.string(from: date)
    }
}
