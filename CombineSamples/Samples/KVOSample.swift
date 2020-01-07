//
//  KVOSample.swift
//  CombineSamples
//
//  Created by Hajime Imamura on 2020/01/06.
//  Copyright © 2020 imamurh. All rights reserved.
//

import SwiftUI
import Combine
import AVFoundation

class KVOSampleViewModel: ObservableObject {

  @Published private(set) var rate: Float = 0
  @Published private(set) var isPlaying = false
  @Published private(set) var buttonTitle = ""

  private var cancellableSet: Set<AnyCancellable> = []

  private let player = AVPlayer(
    // https://developer.apple.com/streaming/examples/
    url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/img_bipbop_adv_example_ts/master.m3u8")!
  )

  init() {
    NSObject.KeyValueObservingPublisher(object: player, keyPath: \.rate, options: [])
      .sink { self.rate = $0 }
      .store(in: &cancellableSet)

    $rate
      .receive(on: RunLoop.main)
      .map { $0 > 0 }
      .assign(to: \.isPlaying, on: self)
      .store(in: &cancellableSet)

    $isPlaying
      .receive(on: RunLoop.main)
      .map { $0 ? "Pause" : "Play" }
      .assign(to: \.buttonTitle, on: self)
      .store(in: &cancellableSet)
  }

  func togglePlayPause() {
    if isPlaying {
      player.pause()
    } else {
      player.play()
    }
  }

  func play() {
    player.play()
  }

  func pause() {
    player.pause()
  }

  func makePlayerView() -> PlayerView {
    PlayerView(player: player)
  }
}

struct KVOSample: View {

  @ObservedObject var viewModel = KVOSampleViewModel()

  var body: some View {
    VStack(spacing: 40) {
      viewModel.makePlayerView()
        .aspectRatio(16/9, contentMode: .fit)
      Text("Rate: \(viewModel.rate)")
      Button(action: {
        self.viewModel.togglePlayPause()
      }) {
        Text(viewModel.buttonTitle)
      }
    }
    .navigationBarTitle("KVO")
    .onDisappear {
      self.viewModel.pause()
    }
  }
}

// MARK: - Player View

final class AVPlayerView: UIView {
  override class var layerClass: AnyClass { return AVPlayerLayer.self }
  var playerLayer: AVPlayerLayer { return layer as! AVPlayerLayer }
  func bind(to player: AVPlayer?) { playerLayer.player = player }
}

struct PlayerView: UIViewRepresentable {
  let player: AVPlayer

  func makeUIView(context: Context) -> AVPlayerView {
    let playerView = AVPlayerView()
    playerView.bind(to: player)
    return playerView
  }

  func updateUIView(_ uiView: AVPlayerView, context: Context) {}
}
