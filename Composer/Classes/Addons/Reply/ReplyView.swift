//
//  ReplyView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/6/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

public struct ReplyViewModel {
    
    public var nameText: String
    public var timeText: String
    public var text: String
    
    public init(nameText: String, timeText: String, text: String) {
        self.nameText = nameText
        self.timeText = timeText
        self.text = text
    }
}

public protocol ReplyViewDelegate: AnyObject {
    
    func replyViewDidHide(_ replyView: ReplyView)
    func replyViewDidShow(_ replyView: ReplyView)
}

public class ReplyView: UIView {
    
    public var mainBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            backgroundView.backgroundColor = mainBackgroundColor
        }
    }
    
    public var nameColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            nameLabel.textColor = nameColor
        }
    }
    
    public var timeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            timeLabel.textColor = timeColor
        }
    }
    
    public var textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            textLabel.textColor = textColor
        }
    }
    
    public var closeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            closeButton.tintColor = closeColor
        }
    }
    
    public weak var delegate: ReplyViewDelegate?
    
    public let backgroundView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.layer.cornerRadius = 4.0
    }
    
    public let nameLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .title3)
        $0.adjustsFontForContentSizeCategory = true
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    public let timeLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .footnote)
        $0.adjustsFontForContentSizeCategory = true
    }
    
    public let textLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.font = .preferredFont(forTextStyle: .body)
        $0.adjustsFontForContentSizeCategory = true
        
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    public let closeButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 20),
            $0.heightAnchor.constraint(equalToConstant: 20)
        ])
        $0.setImage(ComposerAssets.cancel, for: .normal)
        $0.addTarget(self, action: #selector(didPressCloseButton(_:)), for: .touchUpInside)
    }
    
    override public var isHidden: Bool {
        didSet {
            if isHidden {
                delegate?.replyViewDidHide(self)
            } else {
                delegate?.replyViewDidShow(self)
            }
        }
    }
    
    public init() {
        super.init(frame: .zero)
        self.commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override public var intrinsicContentSize: CGSize {
        let height = isHidden ? 0.0 : 10.0 +
            nameLabel.intrinsicContentSize.height +
            textLabel.intrinsicContentSize.height +
            3.0 + 15.0 + 13.0
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        clipsToBounds = true
        isHidden = true
        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })
        addSubviews()
        setupConstraints()
        backgroundView.backgroundColor = mainBackgroundColor
        nameLabel.textColor = nameColor
        timeLabel.textColor = timeColor
        textLabel.textColor = textColor
        closeButton.tintColor = closeColor
    }
    
    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(backgroundView)
        backgroundView.addSubview(nameLabel)
        backgroundView.addSubview(timeLabel)
        backgroundView.addSubview(textLabel)
        addSubview(closeButton)
    }
    
    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: layoutMargins.left),
            backgroundView.trailingAnchor.constraint(equalTo: closeButton.leadingAnchor, constant: -10.0),
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: layoutMargins.top),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0.0),
            nameLabel.leadingAnchor.constraint(equalTo: backgroundView.leadingAnchor, constant: 15.0),
            nameLabel.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 13.0),
            timeLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 10.0),
            timeLabel.bottomAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 0.0),
            timeLabel.trailingAnchor.constraint(lessThanOrEqualTo: backgroundView.trailingAnchor, constant: -15.0),
            textLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: 0.0),
            textLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 3.0),
            textLabel.trailingAnchor.constraint(equalTo: backgroundView.trailingAnchor, constant: -16.0),
            closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -layoutMargins.right),
            closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 15.0)
        ])
    }
}

// MARK: - Actions & Observers

extension ReplyView {
    
    @objc func didPressCloseButton(_ sender: Any) {
        if sender as AnyObject === closeButton {
            UIView.animate(withDuration: 0.2) {
                self.isHidden = true
            }
        }
    }
}
