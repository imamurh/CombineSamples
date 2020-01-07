//
//  ContentView.swift
//  CombineSamples
//
//  Created by Hajime Imamura on 2020/01/06.
//  Copyright © 2020 imamurh. All rights reserved.
//

import SwiftUI

enum CombineSample: String, Identifiable, CaseIterable {
  case notificationCenter
  case timer
  case kvo

  var id: String { return rawValue }

  var description: String {
    switch self {
    case .notificationCenter: return "NotificationCenter"
    case .timer: return "Timer"
    case .kvo: return "KVO"
    }
  }

  var view: some View {
    switch self {
    case .notificationCenter: return AnyView(NotificationCenterSample())
    case .timer: return AnyView(TimerSample())
    case .kvo: return AnyView(KVOSample())
    }
  }
}

struct ContentView: View {

  var body: some View {
    NavigationView {
      List(CombineSample.allCases) { sample in
        NavigationLink(destination: sample.view) {
          Text(sample.description)
        }
      }
      .navigationBarTitle("Combine Samples")
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}
