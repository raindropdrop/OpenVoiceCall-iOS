//
//  RoomViewController.swift
//  OpenVoiceCall
//
//  Created by GongYuhua on 16/8/22.
//  Copyright © 2016年 Agora. All rights reserved.
//

import UIKit

protocol RoomVCDelegate: class {
    func roomVCNeedClose(roomVC: RoomViewController)
}

class RoomViewController: UIViewController {
    
    @IBOutlet weak var roomNameLabel: UILabel!
    @IBOutlet weak var logTableView: UITableView!
    @IBOutlet weak var muteAudioButton: UIButton!
    @IBOutlet weak var speakerButton: UIButton!
    
    var roomName: String!
    weak var delegate: RoomVCDelegate?
    
    private var agoraKit: AgoraRtcEngineKit!
    private var logs = [String]()
    
    private var audioMuted = false {
        didSet {
            muteAudioButton?.setImage(UIImage(named: audioMuted ? "btn_mute_blue" : "btn_mute"), forState: .Normal)
            agoraKit.muteLocalAudioStream(audioMuted)
        }
    }
    
    private var speakerEnabled = true {
        didSet {
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker_blue" : "btn_speaker"), forState: .Normal)
            speakerButton?.setImage(UIImage(named: speakerEnabled ? "btn_speaker" : "btn_speaker_blue"), forState: .Highlighted)
            
            agoraKit.setEnableSpeakerphone(speakerEnabled)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        roomNameLabel.text = "\(roomName)"
        logTableView.rowHeight = UITableViewAutomaticDimension
        logTableView.estimatedRowHeight = 25
        loadAgoraKit()
    }
    
    @IBAction func doMuteAudioPressed(sender: UIButton) {
        audioMuted = !audioMuted
    }
    
    @IBAction func doSpeakerPressed(sender: UIButton) {
        speakerEnabled = !speakerEnabled
    }
    
    @IBAction func doClosePressed(sender: UIButton) {
        leaveChannel()
    }
}

private extension RoomViewController {
    func appendLog(string: String) {
        guard !string.isEmpty else {
            return
        }
        
        logs.append(string)
        
        var deleted: String?
        if logs.count > 200 {
            deleted = logs.removeFirst()
        }
        
        updateLogTableWithDeletedString(deleted)
    }
    
    func updateLogTableWithDeletedString(deleted: String?) {
        guard let tableView = logTableView else {
            return
        }
        
        let insertIndexPath = NSIndexPath(forRow: logs.count - 1, inSection: 0)
        
        tableView.beginUpdates()
        if deleted != nil {
            tableView.deleteRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .None)
        }
        tableView.insertRowsAtIndexPaths([insertIndexPath], withRowAnimation: .None)
        tableView.endUpdates()
        
        tableView.scrollToRowAtIndexPath(insertIndexPath, atScrollPosition: .Bottom, animated: false)
    }
}

//MARK: - table view
extension RoomViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logs.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("logCell", forIndexPath: indexPath) as! LogCell
        cell.setLog(logs[indexPath.row])
        return cell
    }
}

//MARK: - engine
private extension RoomViewController {
    func loadAgoraKit() {
        agoraKit = AgoraRtcEngineKit.sharedEngineWithAppId(KeyCenter.AppId, delegate: self)
        
        let code = agoraKit.joinChannelByKey(nil, channelName: roomName, info: nil, uid: 0, joinSuccess: nil)
        
        if code != 0 {
            dispatch_async(dispatch_get_main_queue(), {
                self.appendLog("Join channel failed: \(code)")
            })
        }
    }
    
    func leaveChannel() {
        agoraKit.leaveChannel(nil)
        delegate?.roomVCNeedClose(self)
    }
}

extension RoomViewController: AgoraRtcEngineDelegate {
    func rtcEngineConnectionDidInterrupted(engine: AgoraRtcEngineKit!) {
        appendLog("Connection Interrupted")
    }
    
    func rtcEngineConnectionDidLost(engine: AgoraRtcEngineKit!) {
        appendLog("Connection Lost")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didOccurError errorCode: AgoraRtcErrorCode) {
        appendLog("Occur error: \(errorCode.rawValue)")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didJoinChannel channel: String!, withUid uid: UInt, elapsed: Int) {
        appendLog("Did joined channel: \(channel), with uid: \(uid), elapsed: \(elapsed)")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didJoinedOfUid uid: UInt, elapsed: Int) {
        appendLog("Did joined of uid: \(uid)")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didOfflineOfUid uid: UInt, reason: AgoraRtcUserOfflineReason) {
        appendLog("Did offline of uid: \(uid), reason: \(reason.rawValue)")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, audioQualityOfUid uid: UInt, quality: AgoraRtcQuality, delay: UInt, lost: UInt) {
        appendLog("Audio Quality of uid: \(uid), quality: \(quality.rawValue), delay: \(delay), lost: \(lost)")
    }
    
    func rtcEngine(engine: AgoraRtcEngineKit!, didApiCallExecute api: String!, error: Int) {
        appendLog("Did api call execute: \(api), error: \(error)")
    }
}
