//
//  ClearButtonTextField.swift
//  DeepReason
//
//  Created by Sierra on 7/6/17.
//  Copyright © 2017 Sierra. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class ClearButtonTextField: SkyFloatingLabelTextFieldWithIcon {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func rightViewRect(forBounds bounds:CGRect) -> CGRect {
        var r = super.rightViewRect(forBounds: bounds)
        r = r.offsetBy(dx: 0, dy: 8);
        return r
    }
    
}
