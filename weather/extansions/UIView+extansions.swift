//
//  UIView+extansions.swift
//  weather
//
//  Created by алексей ганзицкий on 16.11.2022.
//

import Foundation
import UIKit

extension UIView {
    func rounded(radius: CGFloat = 15) {
        self.layer.cornerRadius = radius
    }
    
    func shadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.white.cgColor
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 20, height: 20)
        layer.shadowRadius = 5
        layer.shadowPath = UIBezierPath(rect: bounds).cgPath // для закруглённых углов
        //        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath // для круга
        layer.shouldRasterize = true
    }
    
    func addParalaxEffect(amount: Int = 20) {
        let horizontal = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount
        let vertical = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount
        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        addMotionEffect(group)
    }
}


