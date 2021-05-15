//
//  Globals.swift
//  SignDetector
//
//  Created by Ярослав Карпунькин on 26.04.2021.
//

import Foundation
import UIKit

public struct Globals {
    public static let screenSize: CGRect = UIScreen.main.bounds
    public static let clusterMaxSignsCount: Int = 100
}

func onMainThread(delay: TimeInterval = 0, _ block: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { block() }
}


