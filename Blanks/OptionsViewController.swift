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

class OptionsViewController: UIViewController {
    @IBOutlet weak var dragSwitch: UISwitch!
    weak var delegate: OptionsViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        let defaults = UserDefaults.standard
        var tapping = dragSwitch.isOn

        if defaults.object(forKey: "TappingUI") != nil {
            tapping = defaults.bool(forKey: "TappingUI")
        }

        dragSwitch.isOn = tapping
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    @IBAction func toggleDragging(_ sender: Any) {
        let prefs = UserDefaults.standard
        print(dragSwitch.isOn)

        prefs.set(dragSwitch.isOn, forKey: "TappingUI")
    }

    @IBAction func done(_ sender: Any) {
        delegate?.optionsViewControllerDidFinish(self)
    }
}
