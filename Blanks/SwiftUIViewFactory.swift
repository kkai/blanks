//
//  SwiftUIViewFactory.swift
//  Blanks
//
//  Created by kai on 22.09.21.
//  Copyright © 2021 Kai Kunze. All rights reserved.
//
import Foundation
import SwiftUI

class SwiftUIViewFactory: NSObject {
    @objc static func makeSwiftUIView(dismissHandler: @escaping (() -> Void)) -> UIViewController {
        return UIHostingController(rootView: SwiftUIView(dismiss: dismissHandler))
    }
}
