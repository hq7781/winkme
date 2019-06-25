//
//  NSData+NumberOfBytes.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import Foundation

internal extension Data {
    internal static func dataWithNumberOfBytes(_ numberOfBytes: Int) -> Data {
        let bytes = malloc(numberOfBytes)
        let data = Data(bytes: bytes!, count: numberOfBytes)
        free(bytes)
        return data
    }
}
