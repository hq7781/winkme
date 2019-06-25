//
//  CBLegacyManagerState.swift
//  BluetoothKit
//
//  Created by Rasmus H. Hummelmose on 21/10/2016.
//  Copyright © 2016 Rasmus Taulborg Hummelmose. All rights reserved.
//

import Foundation
import CoreBluetooth

extension CBCentralManager {

    internal var centralManagerState: CBManagerState {
        get {
            return CBManagerState(rawValue: state.rawValue) ?? .unknown
        }
    }
}

extension CBPeripheralManager {

    internal var peripheralManagerState: CBManagerState {
        get {
            return CBManagerState(rawValue: state.rawValue) ?? .unknown
        }
    }

}
