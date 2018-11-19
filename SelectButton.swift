//
//  SelectButton.swift
//  LPHSignageLive
//
//  Created by Tom Murray on 19/11/2018.
//  Copyright © 2018 Tom Murray. All rights reserved.
//

import UIKit

class SelectButton: UIButton {


    override func draw(_ rect: CGRect) {
        super.draw(rect)
		layer.cornerRadius = self.frame.height / 2
    }
	

}
