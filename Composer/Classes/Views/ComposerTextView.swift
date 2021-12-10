//
//  ComposerTextView.swift
//  RocketChatViewController Example
//
//  Created by Matheus Cardoso on 9/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//
//  Modified version of MoZhouqi/KMPlaceholderTextView ;)
//

import UIKit

public protocol ComposerTextViewDelegate: class {
    func maximumHeight(for composerTextView: ComposerTextView) -> CGFloat
}

public class FallbackComposerTextViewDelegate: ComposerTextViewDelegate {
    public func maximumHeight(for composerTextView: ComposerTextView) -> CGFloat {
        return 200.0
    }
}

public class ComposerTextView: UITextView {
    
    
    
    public let placeholderLabel: UILabel = UILabel()
    
    public var placeholderColor = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1) {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    
    public var borderColor  = #colorLiteral(red: 0.3098039329, green: 0.01568627544, blue: 0.1294117719, alpha: 1) {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    private var placeholderLabelConstraints = [NSLayoutConstraint]()

    public weak var textViewDelegate: ComposerTextViewDelegate?
    let fallbackDelegate = FallbackComposerTextViewDelegate()
    var currentDelegate: ComposerTextViewDelegate {
        return textViewDelegate ?? fallbackDelegate
    }

    public override var font: UIFont! {
        didSet {
            placeholderLabel.font = placeholderLabel.font ?? font
        }
    }

    public override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    public override var text: String! {
        didSet {
            textDidChange()
        }
    }

    public override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }

    public override var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }

    public override var intrinsicContentSize: CGSize {
        let height = min(contentSize.height, currentDelegate.maximumHeight(for: self))
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }

    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(textDidChange), name: UITextView.textDidChangeNotification, object: nil)

        placeholderLabel.addObserver(self, forKeyPath: "bounds", options: .new, context: nil)
        self.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)

        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)
        updateConstraintsForPlaceholderLabel()
		self.textContainerInset = UIEdgeInsets(top: 12, left: 5, bottom: 10, right: 5 + 24 + 16)
		self.layer.cornerRadius = 16
		self.layer.borderWidth = 1
		self.layer.borderColor = placeholderColor.cgColor
    }

    private func updateConstraintsForPlaceholderLabel() {
		let newConstraints = [NSLayoutConstraint(item: placeholderLabel, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 12),
							  NSLayoutConstraint(item: placeholderLabel, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 12),
							  NSLayoutConstraint(item: placeholderLabel, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 16),
							  NSLayoutConstraint(item: placeholderLabel, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 16)]
//        let newConstraints = NSLayoutConstraint.constraints(
//            withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding + 12))-[placeholder]",
//            options: [],
//            metrics: nil,
//            views: ["placeholder": placeholderLabel]
//        ) + NSLayoutConstraint.constraints(
//            withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
//            options: [],
//            metrics: nil,
//            views: ["placeholder": placeholderLabel]
//        ) + [NSLayoutConstraint(
//            item: placeholderLabel,
//            attribute: .width,
//            relatedBy: .equal,
//            toItem: self,
//            attribute: .width,
//            multiplier: 1.0,
//            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
//        )]

        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }

    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    }

}

// MARK: Observers & Actions

public extension ComposerTextView {
    /**
     Called when the content size of the placeholder label changes and adjusts the content size.
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if object as AnyObject? === placeholderLabel && keyPath == "bounds" {
            if text.isEmpty {
                text = placeholderLabel.text
                self.contentSize = CGSize(width: contentSize.width, height: sizeThatFits(CGSize(width: contentSize.width, height: .greatestFiniteMagnitude)).height)
                text = ""
            }
        }
    }
}

// MARK: Helper Methods

public extension ComposerTextView {
    var rangeOfNearestWordToSelection: Range<String.Index>? {
        guard let range = Range(selectedRange, in: text) else {
            return nil
        }

        let wordRanges = Array(text.indices).filter {
            text[$0] != " " && ($0 == text.startIndex || text[text.index(before: $0)] == " ")
        }.map { index -> Range<String.Index> in
                if let spaceIndex = text[index...].firstIndex(of: " ") {
                    return index..<spaceIndex
                }

                return index..<text.endIndex
        }

        return wordRanges.first {
            if range.lowerBound == text.startIndex {
                return $0.lowerBound == text.startIndex
            }

            return range.lowerBound == $0.lowerBound || $0.contains(text.index(before: range.lowerBound))
        }
    }
}
