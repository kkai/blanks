//
//  FlipsideViewController.swift
//  MoreBlanks
//
//  Created by Kai Kunze on 19/10/2013.
//  Copyright (c) 2013 Kai Kunze. All rights reserved.
//

import UIKit

protocol FlipsideViewControllerDelegate: AnyObject {
    func flipsideViewControllerDidFinish(_ controller: FlipsideViewController)
}

class FlipsideViewController: UIViewController {
    weak var delegate: FlipsideViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions

    @IBAction func done(_ sender: Any) {
        delegate?.flipsideViewControllerDidFinish(self)
    }
}
