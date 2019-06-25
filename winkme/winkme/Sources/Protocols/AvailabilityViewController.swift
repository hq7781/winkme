//
//  AvailabilityViewController.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit
import BluetoothKit

protocol AvailabilityViewController: BKAvailabilityObserver {
    var availabilityView: AvailabilityView { get set }
    var heightForAvailabilityView: CGFloat { get }
    func applyAvailabilityView()
}

extension AvailabilityViewController where Self: UIViewController {

    // MARK: Properties
    internal var heightForAvailabilityView: CGFloat {
        return CGFloat(45)
    }

    // MARK: Functions
    internal func applyAvailabilityView() {
        view.addSubview(availabilityView)
        availabilityView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalTo(view)
            make.height.equalTo(heightForAvailabilityView)
        }
    }

    // MARK: BKAvailabilityObserver
    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        availabilityView.availabilityObserver(availabilityObservable, availabilityDidChange: availability)
    }

    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        availabilityView.availabilityObserver(availabilityObservable, unavailabilityCauseDidChange: unavailabilityCause)
    }
}
