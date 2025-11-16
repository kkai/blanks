//
//  MainViewController.swift
//  MoreBlanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit

final class MainViewController: UIViewController, FlipsideViewControllerDelegate {

    // MARK: - Flipside View

    func flipsideViewControllerDidFinish(_ controller: FlipsideViewController) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SegueIdentifier.showAlternate.rawValue {
            if let destination = segue.destination as? FlipsideViewController {
                destination.delegate = self
            }
        }
    }
}
