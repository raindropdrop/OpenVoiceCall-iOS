//
//  MainViewController.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/8/17.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {
    
    @IBOutlet weak var roomNameTextField: UITextField!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let segueId = segue.identifier where segueId == "mainToRoom",
            let roomName = sender as? String else {
            return
        }
        
        let roomVC = segue.destinationViewController as! RoomViewController
        roomVC.roomName = roomName
        roomVC.delegate = self
    }
    
    @IBAction func doRoomNameTextFieldEditing(sender: UITextField) {
        if let text = sender.text where !text.isEmpty {
            let legalString = MediaCharacter.updateToLegalMediaString(text)
            sender.text = legalString
        }
    }
    
    @IBAction func doJoinPressed(sender: UIButton) {
        enterRoom(roomNameTextField.text)
    }
}

private extension MainViewController {
    func enterRoom(roomName: String?) {
        guard let roomName = roomName where !roomName.isEmpty else {
            return
        }
        performSegueWithIdentifier("mainToRoom", sender: roomName)
    }
}

extension MainViewController: RoomVCDelegate {
    func roomVCNeedClose(roomVC: RoomViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension MainViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        enterRoom(textField.text)
        return true
    }
}
