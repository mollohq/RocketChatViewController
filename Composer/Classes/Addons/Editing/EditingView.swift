//
//  EditingView.swift
//  DifferenceKit
//
//  Created by Matheus Cardoso on 9/28/18.
//

import UIKit

public protocol EditingViewDelegate: AnyObject {
    
    func editingViewDidHide(_ editingView: EditingView)
    func editingViewDidShow(_ editingView: EditingView)
}

public class EditingView: UIView, ComposerLocalizable {
    
    public var titleColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            titleLabel.textColor = titleColor
        }
    }
    
    public var closeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            closeButton.tintColor = closeColor
        }
    }
    
    public weak var delegate: EditingViewDelegate?
    
    override public var isHidden: Bool {
        didSet {
            if isHidden {
                delegate?.editingViewDidHide(self)
            } else {
                delegate?.editingViewDidShow(self)
            }
        }
    }
    
    public let titleLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.text = localized(.editingViewTitle)
        $0.font = .preferredFont(forTextStyle: .headline)
        $0.adjustsFontForContentSizeCategory = true
        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }
    
    public let closeButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(ComposerAssets.cancel, for: .normal)
        $0.addTarget(self, action: #selector(didPressCloseButton(_:)), for: .touchUpInside)
        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: 20),
            $0.heightAnchor.constraint(equalToConstant: 20)
        ])
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
    
    override public var intrinsicContentSize: CGSize {
        let height = isHidden ? 0 : layoutMargins.top + titleLabel.intrinsicContentSize.height + layoutMargins.bottom
        return CGSize(width: super.intrinsicContentSize.width, height: height)
    }
    
    override public func layoutSubviews() {
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
        
        titleLabel.textColor = titleColor
        closeButton.tintColor = closeColor
    }
    
    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(closeButton)
    }
    
    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: layoutMargins.left),
            titleLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: layoutMargins.top),
            closeButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -layoutMargins.right),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: layoutMargins.top)
        ])
    }
}

// MARK: - Actions & Observers

extension EditingView {
    
    @objc func didPressCloseButton(_ sender: Any) {
        if sender as AnyObject === closeButton {
            UIView.animate(withDuration: 0.2) {
                self.isHidden = true
            }
        }
    }
}
