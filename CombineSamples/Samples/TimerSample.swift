//
//  TimerSample.swift
//  CombineSamples
//
//  Created by Hajime Imamura on 2020/01/06.
//  Copyright © 2020 imamurh. All rights reserved.
//

import SwiftUI
import Combine

class TimerSampleViewModel: ObservableObject {

  @Published private(set) var count = 0
  @Published private(set) var isRunning = false
  @Published private(set) var buttonTitle = ""

  private var cancellableSet: Set<AnyCancellable> = []
  private var timerCancellableSet: Set<AnyCancellable> = []

  init() {
    $count
      .receive(on: RunLoop.main)
      .map { $0 > 0 }
      .assign(to: \.isRunning, on: self)
      .store(in: &cancellableSet)

    $isRunning
      .receive(on: RunLoop.main)
      .map { $0 ? "Stop" : "Start" }
      .assign(to: \.buttonTitle, on: self)
      .store(in: &cancellableSet)
  }

  func start() {
    count = 10
    $count
      .sink { if $0 <= 0 { self.stop() } }
      .store(in: &timerCancellableSet)

    Timer.publish(every: 1, on: .main, in: .common)
      .autoconnect()
      .sink { _ in self.count -= 1 }
      .store(in: &timerCancellableSet)
  }

  func stop() {
    timerCancellableSet.removeAll()
    count = 0
  }
}

struct TimerSample: View {

  @ObservedObject var viewModel = TimerSampleViewModel()

  var body: some View {
    VStack(spacing: 40) {
      Text("Count: \(viewModel.count)")
      Button(action: {
        if !self.viewModel.isRunning {
          self.viewModel.start()
        } else {
          self.viewModel.stop()
        }
      }) {
        Text(viewModel.buttonTitle)
      }
    }
    .navigationBarTitle("Timer")
  }
}
