//
//  AudioEngine.Player.swift
//  Example
//
//  Created by 吴熠 on 4/6/22.
//

import Foundation
import AVFoundation

@available(iOS 13.0, *)
extension AudioEngine {

  public final class Player {

    let audioFile: AVAudioFile

    lazy var audioFormat = audioFile.processingFormat

    lazy var length = audioFile.length

    lazy var sampleRate = audioFormat.sampleRate

    public lazy var duration: TimeInterval = Double(length) / sampleRate

    var playerNode: AVAudioPlayerNode?

    var raterNode: AVAudioUnitTimePitch?

    var willStart: (() -> Bool)?

    var didPause: (() -> Void)?

    var didStop: (() -> Void)?

    var queue: DispatchQueue?

    lazy var updater: Updater = {
      let updater = Updater()
      updater.preferredUpdatesPerSecond = 4
      updater.onUpdate = { [unowned self] in self.updatePosition() }
      return updater
    }()

    /// Current player time. Main queue. Unique values.
    @Observable public private(set) var time: TimeInterval = 0.0

    @Observable public private(set) var state = State.stopped {
      didSet {
        guard state != oldValue else { return }
        updater.isPaused = !state.isPlaying

        switch state {
        case .playing: break
        case .paused: didPause?()
        case .stopped: didStop?()
        }
      }
    }

    public var loop = true

    public var rate: Float = 1.0 {
      didSet {
        queue?.async {
          self.raterNode?.rate = self.rate
        }
      }
    }

    public var volume: Float = 1.0 {
      didSet {
        queue?.async {
          self.playerNode?.volume = self.volume
        }
      }
    }

    var position: AVAudioFramePosition = 0 {
      didSet {
        guard position != oldValue else { return }
        time = TimeInterval(position) / sampleRate
      }
    }

    var segment = 0

    public init(url: URL) throws { audioFile = try AVAudioFile(forReading: url) }

    deinit { self.state = self.state.stop(self) }

    func attach(
      playerNode: AVAudioPlayerNode,
      raterNode: AVAudioUnitTimePitch,
      queue: DispatchQueue
    ) {
      self.playerNode = playerNode
      self.raterNode = raterNode
      self.queue = queue

      queue.async {
        raterNode.rate = self.rate
        playerNode.volume = self.volume
        self.state = self.state.attach(self)
      }
    }

    func assertEngine() {
      assert(playerNode != nil, "Player must be attached to AudioEngine")
      assert(raterNode != nil, "Player must be attached to AudioEngine")
      assert(queue != nil, "Player must be attached to AudioEngine")
    }

    public func play() {
      assertEngine()
      queue?.async { self.state = self.state.play(self) }
    }

    public func pause() {
      assertEngine()
      queue?.async { self.state = self.state.pause(self) }
    }

    public func stop() {
      assertEngine()
      queue?.async { self.state = self.state.stop(self) }
    }

    func seek(by time: TimeInterval) {
      assertEngine()
      queue?.async { self.state = self.state.seek(self, by: time) }
    }

    func seek(to time: TimeInterval) {
      assertEngine()
      queue?.async { self.state = self.state.seek(self, to: time) }
    }
  }
}

// MARK: - Scheduling
@available(iOS 13.0, *)
extension AudioEngine.Player {

  func schedule(
    _ playerNode: AVAudioPlayerNode,
    at position: AVAudioFramePosition
  ) {
    let frameCount = AVAudioFrameCount(length - position)

    guard frameCount > 0 else { return }
    schedule(playerNode, at: position, frameCount: frameCount)
  }

  func schedule(
    _ playerNode: AVAudioPlayerNode,
    at position: AVAudioFramePosition,
    frameCount: AVAudioFrameCount
  ) {
    segment += 1
    playerNode.scheduleSegment(
      audioFile,
      startingFrame: position,
      frameCount: frameCount,
      at: nil,
      completionCallbackType: .dataRendered
    ) { [weak self, segment] _ in
      self?.playbackFinished(segment: segment)
    }
  }

  func playbackFinished(segment: Int) {
    queue?.async { self.state = self.state.playbackFinished(self, segment: segment) }
  }
}

// MARK: - Time
@available(iOS 13.0, *)
extension AudioEngine.Player {

  func updatePosition() {
    guard let queue = queue else { return }
    position = queue.sync { state.getPosition(self) }
  }
}
