//
//  UINavigationController+Extensions.swift
//  Dogsgram
//
//  Created by Pawel Masiewicz on 2/28/22.
//

import Foundation
import UIKit

extension UINavigationController {
    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
