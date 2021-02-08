//
//  Functions.swift
//  MyLocations
//
//  Created by Wm. Zazeckie on 2/7/21.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds , execute: run)
}
