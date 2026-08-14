//
//  IAPManager.swift
//  Blanks
//
//  Created by kai on 22.09.21.
//  Copyright © 2021 Kai Kunze. All rights reserved.
//

import Foundation
import SwiftUI

class IAPManager: ObservableObject {
    static let shared = IAPManager()

    @Published var inPaymentProgress = false

    init() {
      
    }

}
