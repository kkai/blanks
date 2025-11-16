//
//  WordView.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import UIKit

class WordView: UIView {
    @IBOutlet weak var label: UILabel!

    func addWord(_ word: String) {
        label.text = word
    }

    func getWord() -> String {
        return label.text ?? ""
    }
}
