//
//  PeripheralViewController.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit
import SnapKit
import BluetoothKit
//import CryptoSwift

internal class PeripheralViewController: UIViewController, AvailabilityViewController, BKPeripheralDelegate, LoggerDelegate, BKRemotePeerDelegate {

    // MARK: Properties

    internal var availabilityView = AvailabilityView()

    private let peripheral = BKPeripheral()
    private let logTextView = UITextView()
    private lazy var sendDataBarButtonItem: UIBarButtonItem! = { UIBarButtonItem(title: "Send Data", style: UIBarButtonItem.Style.plain, target: self, action: #selector(PeripheralViewController.sendData)) }()

    // MARK: UIViewController Life Cycle
    internal override func viewDidLoad() {
        navigationItem.title = "Peripheral"
        view.backgroundColor = UIColor.white
        Logger.delegate = self
        applyAvailabilityView()
        logTextView.isEditable = false
        logTextView.alwaysBounceVertical = true
        view.addSubview(logTextView)
        applyConstraints()
        startPeripheral()
        sendDataBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = sendDataBarButtonItem
    }

    deinit {
        _ = try? peripheral.stop()
    }

    // MARK: Functions

    private func applyConstraints() {
        logTextView.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(availabilityView.snp.top)
        }
    }

    private func startPeripheral() {
        do {
            peripheral.delegate = self
            peripheral.addAvailabilityObserver(self)
            //            let dataServiceUUID = UUID(uuidString: "6E6B5C64-FAF7-40AE-9C21-D4933AF45B23")!
            //            let dataServiceCharacteristicUUID = UUID(uuidString: "477A2967-1FAB-4DC5-920A-DEE5DE685A3D")!
            let dataServiceUUID = UUID(uuidString:"C70CB8F3-BB87-4412-B2D4-A90702ABDA0F")!
            let dataServiceCharacteristicUUID = UUID(uuidString: "629B4394-7040-49C5-B0D0-218AB5FC92CD")!
            let localName = Bundle.main.infoDictionary!["CFBundleName"] as? String
            let configuration = BKPeripheralConfiguration(dataServiceUUID: dataServiceUUID, dataServiceCharacteristicUUID: dataServiceCharacteristicUUID, localName: localName)
            try peripheral.startWithConfiguration(configuration)
            Logger.log("Awaiting connections from remote centrals")
        } catch let error {
            print("Error starting: \(error)")
        }
    }

    private func refreshControls() {
        sendDataBarButtonItem.isEnabled = peripheral.connectedRemoteCentrals.count > 0
    }

    // MARK: Target Actions
    @objc private func sendData() {
        let numberOfBytesToSend: Int = Int(arc4random_uniform(950) + 50)
        let data = Data.dataWithNumberOfBytes(numberOfBytesToSend)
        //        Logger.log("Prepared \(numberOfBytesToSend) bytes with MD5 hash: \(data.md5().toHexString())")
        for remoteCentral in peripheral.connectedRemoteCentrals {
            Logger.log("Sending to \(remoteCentral)")
            peripheral.sendData(data, toRemotePeer: remoteCentral) { data, remoteCentral, error in
                guard error == nil else {
                    Logger.log("Failed sending to \(remoteCentral)")
                    return
                }
                Logger.log("Sent to \(remoteCentral)")
            }
        }
    }

    // MARK: BKPeripheralDelegate
    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidConnect remoteCentral: BKRemoteCentral) {
        Logger.log("Remote central did connect: \(remoteCentral)")
        remoteCentral.delegate = self
        refreshControls()
    }

    internal func peripheral(_ peripheral: BKPeripheral, remoteCentralDidDisconnect remoteCentral: BKRemoteCentral) {
        Logger.log("Remote central did disconnect: \(remoteCentral)")
        refreshControls()
    }

    // MARK: BKRemotePeerDelegate
    func remotePeer(_ remotePeer: BKRemotePeer, didSendArbitraryData data: Data) {
        //        Logger.log("Received data of length: \(data.count) with hash: \(data.md5().toHexString())")
    }

    // MARK: LoggerDelegate
    internal func loggerDidLogString(_ string: String) {
        if logTextView.text.count > 0 {
            logTextView.text = logTextView.text + ("\n" + string)
        } else {
            logTextView.text = string
        }
        logTextView.scrollRangeToVisible(NSRange(location: logTextView.text.count - 1, length: 1))
    }
}
