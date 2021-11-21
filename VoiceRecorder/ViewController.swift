//
//  ViewController.swift
//  VoiceRecorder
//
//  Created by Becerra Borges, Eduardo Yorman on 20/11/21.
//  Copyright © 2021 Sakura Software. All rights reserved.
//

import UIKit
import AVFoundation

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

class ViewController: UIViewController {

    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!

    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!

    override func viewDidLoad() {
        super.viewDidLoad()
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        printMessage(message: "Failed to record.")
                    }
                }
            }
        } catch {
            printMessage(message: "Failed to record.")
        }
    }

    func printMessage(message: String) {
        #if DEBUG
            Swift.print(message)
        #endif
    }

    func loadRecordingUI() {
        recordButton.isHidden = false
        recordButton.setTitle("Tap to record", for: .normal)
    }

    @IBAction func recordButtonPressed(_ sender: UIButton) {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }

    @IBAction func playButtonPressed(_ sender: UIButton) {
        if audioPlayer == nil {
            startPlayback()
        } else {
            finishPlayback()
        }
    }

    // MARK: - Recording

    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            recordButton.setTitle("Tap to stop", for: .normal)
        } catch {
            finishRecording(success: false)
        }
    }

    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        if success {
            recordButton.setTitle("Tap to re-record", for: .normal)
            playButton.setTitle("Play your recording", for: .normal)
            playButton.isHidden = false
        } else {
            recordButton.setTitle("Tap to record", for: .normal)
            playButton.isHidden = true
            printMessage(message: "Recording failed.")
        }
    }

    // MARK: - Playback

    func startPlayback() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.m4a")
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: audioFilename)
            audioPlayer.delegate = self
            audioPlayer.play()
            playButton.setTitle("Stop playback", for: .normal)
        } catch {
            playButton.isHidden = true
            printMessage(message: "Unable to play recording.")
        }
    }

    func finishPlayback() {
        audioPlayer = nil
        playButton.setTitle("Play your recording", for: .normal)
    }
}

extension ViewController: AVAudioRecorderDelegate {

    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}

extension ViewController: AVAudioPlayerDelegate {

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        finishPlayback()
    }
}
