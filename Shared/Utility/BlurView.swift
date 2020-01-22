//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI

struct BlurView: UIViewRepresentable {
  let style: UIBlurEffect.Style
  
  func makeUIView(context: UIViewRepresentableContext<BlurView>) -> UIView {
    let view = UIView(frame: .zero)
    view.backgroundColor = .clear
    let blurEffect = UIBlurEffect(style: style)
    let visualEffectView = UIVisualEffectView(effect: blurEffect)
    visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    view.addSubview(visualEffectView)
    return view
  }
  
  func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<BlurView>) {
  }
}
