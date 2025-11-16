//
//  FlipsideViewController.swift
//  MoreBlanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit

/// Delegate protocol for flipside view dismissal
protocol FlipsideViewControllerDelegate: AnyObject {
    func flipsideViewControllerDidFinish(_ controller: FlipsideViewController)
}

/// Flipside view controller for additional settings or information
final class FlipsideViewController: UIViewController {
    weak var delegate: FlipsideViewControllerDelegate?

    // MARK: - Actions

    @IBAction func done(_ sender: Any) {
        delegate?.flipsideViewControllerDidFinish(self)
    }
}
