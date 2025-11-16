//
//  OptionsViewController.swift
//  Blanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit

protocol OptionsViewControllerDelegate: AnyObject {
    func optionsViewControllerDidFinish(_ controller: OptionsViewController)
}

final class OptionsViewController: UIViewController {
    @IBOutlet private weak var dragSwitch: UISwitch!
    weak var delegate: OptionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        let tapping = defaults.object(forKey: .tappingUI) != nil
            ? defaults.bool(forKey: .tappingUI)
            : false

        dragSwitch.isOn = tapping
    }

    // MARK: - Actions

    @IBAction func toggleDragging(_ sender: Any) {
        let prefs = UserDefaults.standard
        prefs.set(dragSwitch.isOn, forKey: .tappingUI)
    }

    @IBAction func done(_ sender: Any) {
        delegate?.optionsViewControllerDidFinish(self)
    }
}
