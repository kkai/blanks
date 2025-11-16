//
//  WordView.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import UIKit

final class WordView: UIView {
    @IBOutlet private weak var label: UILabel!

    var word: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }

    func addWord(_ word: String) {
        self.word = word
    }

    func getWord() -> String {
        return word
    }
}
