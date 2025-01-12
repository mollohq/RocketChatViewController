//
//  ComposerAddon.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public struct ComposerAddon {
    
    public let viewType: UIView.Type

    public static func == (lhs: ComposerAddon, rhs: ComposerAddon) -> Bool {
        return lhs.viewType == rhs.viewType
    }
}

public extension ComposerAddon {
    
    static var reply: ComposerAddon {
        return ComposerAddon(viewType: ReplyView.self)
    }

    static var hints: ComposerAddon {
        return ComposerAddon(viewType: HintsView.self)
    }

    static var editing: ComposerAddon {
        return ComposerAddon(viewType: EditingView.self)
    }
}
