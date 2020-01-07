//
//  NotificationCenterSample.swift
//  CombineSamples
//
//  Created by Hajime Imamura on 2020/01/06.
//  Copyright © 2020 imamurh. All rights reserved.
//

import SwiftUI
import UIKit
import Combine

extension Notification.Name {
  static let sampleNotification = Notification.Name("sampleNotification")
}

class NotificationCenterSampleViewModel: ObservableObject {

  @Published private(set) var count = 0

  private var cancellableSet: Set<AnyCancellable> = []

  init() {
    NotificationCenter.default
      .publisher(for: .sampleNotification)
      .compactMap { $0.userInfo?["newCount"] as? Int }
      .assign(to: \.count, on: self)
      .store(in: &cancellableSet)

    NotificationCenter.default
      .publisher(for: UIApplication.didEnterBackgroundNotification)
      .sink { _ in self.count = 0 }
      .store(in: &cancellableSet)
  }
}

struct NotificationCenterSample: View {

  @ObservedObject var viewModel = NotificationCenterSampleViewModel()

  var body: some View {
    VStack(spacing: 40) {
      Text("Count: \(viewModel.count)")
      Button(action: {
        NotificationCenter.default.post(
          name: .sampleNotification,
          object: nil,
          userInfo: ["newCount": self.viewModel.count + 1]
        )
      }) {
        Text("Post notification")
      }
    }
    .navigationBarTitle("NotificationCenter")
  }
}
