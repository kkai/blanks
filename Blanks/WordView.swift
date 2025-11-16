//
//  WordView.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import UIKit

/// Custom view for displaying a word option in the quiz game
///
/// WordView is a simple UIView wrapper around a UILabel that displays
/// a word. It's designed to be loaded from a XIB file and used with
/// gesture recognizers for drag-and-drop or tap interactions.
final class WordView: UIView {
    @IBOutlet private weak var label: UILabel!

    /// The word text displayed in this view
    var word: String {
        get { label.text ?? "" }
        set { label.text = newValue }
    }
}
