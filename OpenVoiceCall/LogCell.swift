//
//  LogCell.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/9/7.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class LogCell: UITableViewCell {

    @IBOutlet weak var logLabel: UILabel!
    
    func setLog(log: String) {
//        backgroundColor = UIColor.clearColor()
        
        logLabel.text = log
    }
}
