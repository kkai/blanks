//
//  OptionsViewController.swift
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit

/// Delegate protocol for options screen dismissal
protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidFinish(_ controller: OptionsViewController)
}

/// View controller for game settings and preferences
///
/// Allows users to configure:
/// - Interaction mode (tap vs. drag)
/// - Other game preferences (future)
final class OptionsViewController: UIViewController {
    // MARK: - Properties

    @IBOutlet private weak var dragSwitch: UISwitch!
    weak var delegate: OptionsViewControllerDelegate?

    @UserDefault(.tappingUI, defaultValue: false)
    private var isTappingMode: Bool

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        dragSwitch.isOn = isTappingMode
    }

    // MARK: - Actions

    @IBAction func toggleDragging(_ sender: Any) {
        isTappingMode = dragSwitch.isOn
    }

    @IBAction func done(_ sender: Any) {
        delegate?.optionsViewControllerDidFinish(self)
    }
}
