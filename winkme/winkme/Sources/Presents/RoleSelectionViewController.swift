//
//  RoleSelectionViewController.swift
//  winkme
//
//  Created by 洪 権 on 2019/06/25.
//  Copyright © 2019 洪 権. All rights reserved.
//

import UIKit
import SnapKit

internal class RoleSelectionViewController: UIViewController {

    // MARK: Properties

    private let offset = CGFloat(20)
    private let buttonColor = UIColor.blue
    private let centralButton = UIButton(type: UIButton.ButtonType.custom)
    private let peripheralButton = UIButton(type: UIButton.ButtonType.custom)

    // MARK: UIViewController Life Cycle

    internal override func viewDidLoad() {
        navigationItem.title = "Select Role"
        view.backgroundColor = UIColor.white
        centralButton.setTitle("Central", for: UIControl.State())
        peripheralButton.setTitle("Peripheral", for: UIControl.State())
        preparedButtons([ centralButton, peripheralButton ], andAddThemToView: view)
        applyConstraints()
        #if os(tvOS)
        peripheralButton.enabled = false
        #endif
    }

    // MARK: Functions

    private func preparedButtons(_ buttons: [UIButton], andAddThemToView view: UIView) {
        for button in buttons {
            button.setBackgroundImage(UIImage.imageWithColor(buttonColor), for: UIControl.State())
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
            #if os(iOS)
            button.addTarget(self, action: #selector(RoleSelectionViewController.buttonTapped(_:)), for: UIControl.Event.touchUpInside)
            #elseif os(tvOS)
            button.addTarget(self, action: #selector(RoleSelectionViewController.buttonTapped(_:)), forControlEvents: UIControlEvents.PrimaryActionTriggered)
            #endif

            view.addSubview(button)
        }
    }

    private func applyConstraints() {
        centralButton.snp.makeConstraints { make in
            make.top.equalTo(topLayoutGuide.snp.bottom).offset(offset)
            make.leading.equalTo(view).offset(offset)
            make.trailing.equalTo(view).offset(-offset)
            make.height.equalTo(peripheralButton)
        }
        peripheralButton.snp.makeConstraints { make in
            make.top.equalTo(centralButton.snp.bottom).offset(offset)
            make.leading.trailing.equalTo(centralButton)
            make.bottom.equalTo(view).offset(-offset)
        }
    }

    // MARK: Target Actions

    @objc private func buttonTapped(_ button: UIButton) {
        if button == centralButton {
            navigationController?.pushViewController(CentralViewController(), animated: true)
        } else if button == peripheralButton {
            #if os(iOS)
            navigationController?.pushViewController(PeripheralViewController(), animated: true)
            #endif
        }
    }

}
