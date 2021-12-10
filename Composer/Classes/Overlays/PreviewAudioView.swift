//
//  PreviewAudioView.swift
//  RocketChatViewController
//
//  Created by Matheus Cardoso on 11/01/2019.
//

import UIKit
import AVFoundation

public protocol PreviewAudioViewDelegate: AnyObject {
    
    func previewAudioView(_ view: PreviewAudioView, didConfirmAudio url: URL)
    func previewAudioView(_ view: PreviewAudioView, didDiscardAudio url: URL)
}

public class PreviewAudioView: UIView, ComposerLocalizable {
    
    public var separatorColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            separatorView.backgroundColor = separatorColor
        }
    }
    
    public var discardTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            discardButton.tintColor = discardTintColor
        }
    }
    
    public var sendTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            sendButton.tintColor = sendTintColor
        }
    }
    
    public weak var composerView: ComposerView?
    public weak var delegate: PreviewAudioViewDelegate?

    public let audioView = tap(AudioView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
    }

    public let discardButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.discardButtonHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.discardButtonWidth),
        ])

        $0.setImage(ComposerAssets.delete, for: .normal)
        $0.addTarget(self, action: #selector(touchUpInsideDiscardButton), for: .touchUpInside)
    }

    public let separatorView = tap(UIView()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.separatorViewHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.separatorViewWidth),
        ])
    }

    public let sendButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.addConstraints([
            $0.heightAnchor.constraint(equalToConstant: Consts.discardButtonHeight),
            $0.widthAnchor.constraint(equalToConstant: Consts.discardButtonWidth),
        ])

        $0.setImage(ComposerAssets.send, for: .normal)
        $0.addTarget(self, action: #selector(touchUpInsideSendButton), for: .touchUpInside)
    }

    public init() {
        super.init(frame: .zero)
        commonInit()
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }

    public override func didMoveToSuperview() {
        super.didMoveToSuperview()

        let transformX = frame.width - (Consts.sendButtonWidth +
                         Consts.sendButtonLeading +
                         Consts.sendButtonTrailing +
                         Consts.separatorViewWidth +
                         Consts.separatorViewLeading +
                         Consts.discardButtonWidth +
                         Consts.discardButtonLeading)

        audioView.transform = CGAffineTransform(translationX: transformX, y: 0)

        sendButton.alpha = 0
        separatorView.alpha = 0
        discardButton.alpha = 0

        UIView.animate(withDuration: 0.25) {
            self.audioView.transform = CGAffineTransform(translationX: 0, y: 0)

            self.sendButton.alpha = 1
            self.separatorView.alpha = 1
            self.discardButton.alpha = 1
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        backgroundColor = .white
        clipsToBounds = true

        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
        
        separatorView.backgroundColor = separatorColor
        discardButton.tintColor = discardTintColor
        sendButton.tintColor = sendTintColor
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(audioView)
        addSubview(discardButton)
        addSubview(separatorView)
        addSubview(sendButton)
    }

    /**
     Sets up constraints between the UI elements.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            audioView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.audioViewLeading),
            audioView.topAnchor.constraint(equalTo: topAnchor, constant: Consts.audioViewTop),
            audioView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Consts.audioViewBottom),

            discardButton.leadingAnchor.constraint(equalTo: audioView.trailingAnchor, constant: Consts.discardButtonLeading),
            discardButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            separatorView.leadingAnchor.constraint(equalTo: discardButton.trailingAnchor, constant: Consts.separatorViewLeading),
            separatorView.centerYAnchor.constraint(equalTo: centerYAnchor),

            sendButton.leadingAnchor.constraint(equalTo: separatorView.trailingAnchor, constant: Consts.sendButtonLeading),
            sendButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Consts.sendButtonTrailing),
            sendButton.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    struct Consts {
        static let audioViewLeading: CGFloat = 10
        static let audioViewTop: CGFloat = 6
        static let audioViewBottom: CGFloat = -6

        static let discardButtonLeading: CGFloat = 20
        static let discardButtonHeight: CGFloat = 20
        static let discardButtonWidth: CGFloat = 20

        static let separatorViewLeading: CGFloat = 20
        static let separatorViewHeight: CGFloat = 24
        static let separatorViewWidth: CGFloat = 1

        static let sendButtonLeading: CGFloat = 20
        static let sendButtonTrailing: CGFloat = -20
        static let sendButtonHeight: CGFloat = 24
        static let sendButtonWidth: CGFloat = 24
    }
}

// MARK: Events

extension PreviewAudioView {

    @objc func touchUpInsideDiscardButton() {
        guard let url = audioView.audioUrl else {
            return
        }

        audioView.player?.stop()
        audioView.player = nil

        delegate?.previewAudioView(self, didDiscardAudio: url)
    }

    @objc func touchUpInsideSendButton() {
        guard let url = audioView.audioUrl else {
            return
        }

        audioView.player?.stop()
        audioView.player = nil

        delegate?.previewAudioView(self, didConfirmAudio: url)
    }

}

// MARK: SwipeIndicatorView

public class AudioView: UIView {
    
    public var mainBackgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1) {
        didSet {
            backgroundColor = mainBackgroundColor
        }
    }
    
    public var minTrackColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            progressSlider.minimumTrackTintColor = minTrackColor
        }
    }
    
    public var maxTrackColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            progressSlider.maximumTrackTintColor = maxTrackColor
        }
    }
    
    public var thumbTintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) {
        didSet {
            progressSlider.thumbTintColor = thumbTintColor
        }
    }
    
    public var playTintColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            playButton.tintColor = playTintColor
        }
    }
    
    public var timeColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) {
        didSet {
            timeLabel.textColor = timeColor
        }
    }
    
    public let playButton = tap(UIButton()) {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.setImage(ComposerAssets.play, for: .normal)

        NSLayoutConstraint.activate([
            $0.widthAnchor.constraint(equalToConstant: Consts.playButtonWidth),
            $0.heightAnchor.constraint(equalToConstant: Consts.playButtonHeight)
        ])

        $0.addTarget(self, action: #selector(didPressPlayButton), for: .touchUpInside)
    }

    public let progressSlider = tap(UISlider()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.value = 0

        $0.addTarget(self, action: #selector(didStartSlidingSlider(_:)), for: .touchDown)
        $0.addTarget(self, action: #selector(didFinishSlidingSlider(_:)), for: .touchUpInside)
        $0.addTarget(self, action: #selector(didChangeValueOfSlider(_:)), for: .valueChanged)
    }

    public let timeLabel = tap(UILabel()) {
        $0.translatesAutoresizingMaskIntoConstraints = false

        $0.text = "0:00"
        $0.font = UIFont.systemFont(ofSize: Consts.timeLabelFontSize)
        $0.adjustsFontForContentSizeCategory = true

        $0.numberOfLines = 1
        $0.lineBreakMode = .byTruncatingTail
    }

    var updateTimer: Timer?
    var audioUrl: URL? {
        didSet {
            playing = false
            try? setupPlayer()
            setupTimer()
        }
    }

    public var player: AVAudioPlayer? {
        didSet {
            player?.delegate = self
        }
    }

    public var playing = false {
        didSet {
            if playing {
                player?.play()
            } else {
                player?.pause()
            }

            let pause = ComposerAssets.pause
            let play = ComposerAssets.play
            playButton.setImage(playing ? pause : play, for: .normal)
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }

    /**
     Shared initialization procedures.
     */
    private func commonInit() {
        backgroundColor = mainBackgroundColor
        layer.cornerRadius = Consts.layerCornerRadius
        clipsToBounds = true

        NotificationCenter.default.addObserver(forName: UIContentSizeCategory.didChangeNotification, object: nil, queue: nil, using: { [weak self] _ in
            self?.setNeedsLayout()
        })

        addSubviews()
        setupConstraints()
        
        progressSlider.minimumTrackTintColor = minTrackColor
        progressSlider.maximumTrackTintColor = maxTrackColor
        progressSlider.thumbTintColor = thumbTintColor
        playButton.tintColor = playTintColor
        timeLabel.textColor = timeColor
    }

    /**
     Adds buttons and other UI elements as subviews.
     */
    private func addSubviews() {
        addSubview(playButton)
        addSubview(progressSlider)
        addSubview(timeLabel)
    }

    /**
     Sets up constraints between the UI elements in the composer.
     */
    private func setupConstraints() {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            playButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Consts.playButtonLeading),
            playButton.centerYAnchor.constraint(equalTo: centerYAnchor),

            progressSlider.leadingAnchor.constraint(equalTo: playButton.trailingAnchor, constant: Consts.progressSliderLeading),
            progressSlider.trailingAnchor.constraint(equalTo: timeLabel.leadingAnchor, constant: Consts.progressSliderTrailing),
            progressSlider.centerYAnchor.constraint(equalTo: centerYAnchor),

            timeLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Consts.timeLabelTrailing),
            timeLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    func setupPlayer() throws {
        if let url = audioUrl {
            let data = try Data(contentsOf: url)
            player = try AVAudioPlayer(data: data)
        }
    }

    func setupTimer() {
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { [weak self] _ in
            guard let self = self, let player = self.player else { return }

            self.progressSlider.maximumValue = Float(player.duration)

            if self.playing {
                self.progressSlider.value = Float(player.currentTime)

                if !player.isPlaying {
                    self.playing = false
                }
            }

            let displayTime = self.playing ? Int(player.currentTime) : Int(player.duration)
            self.timeLabel.text = String(format: "%01d:%02d", (displayTime/60) % 60, displayTime % 60)
        }
    }

    struct Consts {
        static let layerCornerRadius: CGFloat = 4

        static let playButtonWidth: CGFloat = 24
        static let playButtonHeight: CGFloat = 24
        static let playButtonLeading: CGFloat = 10

        static let progressSliderLeading: CGFloat = 10
        static let progressSliderTrailing: CGFloat = -15

        static let timeLabelTrailing: CGFloat = -15
        static let timeLabelFontSize: CGFloat = 14
    }
}

// MARK: AVAudioPlayerDelegate

extension AudioView: AVAudioPlayerDelegate {

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        playing = false
        progressSlider.value = 0.0
    }

}

// MARK: Events

extension AudioView {

    @objc func didStartSlidingSlider(_ sender: UISlider) {
        playing = false
    }

    @objc func didFinishSlidingSlider(_ sender: UISlider) {
        player?.currentTime = Double(sender.value)
        playing = true
    }

    @objc func didChangeValueOfSlider(_ sender: UISlider) {
        if player?.currentTime ?? 0.0 > Double(sender.value) {
            playing = false
        }
    }

    @objc func didPressPlayButton(_ sender: UIButton) {
        playing = !playing
    }

}
