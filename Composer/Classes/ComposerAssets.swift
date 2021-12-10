//
//  ComposerAssets.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public struct ComposerAssets {
    
    public static let mic = imageNamed("mic_icon")
    public static let clip = imageNamed("clip_icon")
    public static let emoji = imageNamed("emoji_icon")
    public static let send = imageNamed("send_icon")
    public static let cancel = imageNamed("cancel_icon")
    
    public static let arrow = imageNamed("arrow_icon")
    
    public static let play = imageNamed("play_icon")
    public static let pause = imageNamed("pause_icon")
    
    public static let delete = imageNamed("delete_icon")
    
    private static let bundle = Bundle(for: ComposerView.self)
    
    private static func imageNamed(_ name: String) -> UIImage {
        let image = UIImage(named: name, in: bundle, compatibleWith: nil)
        return image ?? UIImage()
    }
    
    // MARK: - Sounds
    
    public static var startAudioRecordSound: URL? {
        return bundle.url(forResource: "start_audio_record", withExtension: "m4a")
    }
    
    public static var cancelAudioRecordSound: URL? {
        return bundle.url(forResource: "cancel_audio_record", withExtension: "m4a")
    }
}
