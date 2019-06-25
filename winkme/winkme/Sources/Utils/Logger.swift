//
//  Logger.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import Foundation

internal protocol LoggerDelegate: class {
    func loggerDidLogString(_ string: String)
}

internal struct Logger {

    // MARK: Properties
    internal static weak var delegate: LoggerDelegate?
    internal static let loggingDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()

    // MARK: Functions
    internal static func log(_ string: String) {
        let date = Date()
        let stringWithDate = "[\(loggingDateFormatter.string(from: date))] \(string)"
        print(stringWithDate, terminator: "")
        Logger.delegate?.loggerDidLogString(stringWithDate)
    }
}
