//
//  AvailabilityView.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit
import BluetoothKit
import SnapKit

internal class AvailabilityView: UIView, BKAvailabilityObserver {

    // Properties
    private let offset = 10
    private let borderHeight = 0.33
    private let borderView = UIView()
    private let contentView = UIView()
    private let statusLabel = UILabel()

    // Initialization
    internal init() {
        super.init(frame: CGRect.zero)
        backgroundColor = UIColor.lightGray
        addSubview(borderView)
        addSubview(contentView)
        contentView.addSubview(statusLabel)
        statusLabel.attributedText = attributedStringForAvailability(nil)
        borderView.backgroundColor = .darkGray
        contentView.backgroundColor = UIColor.clear
        statusLabel.textAlignment = NSTextAlignment.center
        applyConstraints()
    }

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    // MARK: Functions
    private func applyConstraints() {
        borderView.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(self)
            make.height.equalTo(borderHeight)
        }
        contentView.snp.makeConstraints { make in
            make.top.equalTo(borderView.snp.bottom)
            make.leading.trailing.bottom.equalTo(self)
        }
        statusLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(contentView).offset(offset)
            make.bottom.trailing.equalTo(contentView).offset(-offset)
        }
    }

    private func attributedStringForAvailability(_ availability: BKAvailability?) -> NSAttributedString {
        let leadingText = "Bluetooth: "
        let trailingText = availabilityLabelTrailingTextForAvailability(availability)
        let string = leadingText + trailingText as NSString
        let attributedString = NSMutableAttributedString(string: string as String)
        attributedString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: 14), range: NSRange(location: 0, length: string.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: string.range(of: leadingText))
        if let availability = availability {
            switch availability {
            case .available: attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: string.range(of: trailingText))
            case .unavailable: attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: string.range(of: trailingText))
            }
        }
        return attributedString
    }

    private func availabilityLabelTrailingTextForAvailability(_ availability: BKAvailability?) -> String {
        if let availability = availability {
            switch availability {
            case .available: return "Available"
            case .unavailable(cause: .poweredOff): return "Unavailable (Powered off)"
            case .unavailable(cause: .resetting): return "Unavailable (Resetting)"
            case .unavailable(cause: .unsupported): return "Unavailable (Unsupported)"
            case .unavailable(cause: .unauthorized): return "Unavailable (Unauthorized)"
            case .unavailable(cause: .any): return "Unavailable"
            }
        } else {
            return "Unknown"
        }
    }

    // MARK: BKAvailabilityObserver

    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, availabilityDidChange availability: BKAvailability) {
        statusLabel.attributedText = attributedStringForAvailability(availability)
    }

    internal func availabilityObserver(_ availabilityObservable: BKAvailabilityObservable, unavailabilityCauseDidChange unavailabilityCause: BKUnavailabilityCause) {
        statusLabel.attributedText = attributedStringForAvailability(.unavailable(cause: unavailabilityCause))
    }
}
