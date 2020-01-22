//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI

struct TextView: UIViewRepresentable {
  var text: String
  @Binding var maxWidth: CGFloat
  @Binding var fontSizeOnMacCatalyst: CGFloat
  
  func makeUIView(context: Context) -> MultilineTextView {
    return MultilineTextView(frame: .zero, maxWidth: maxWidth)
  }
  
  func updateUIView(_ uiView: MultilineTextView, context: Context) {
    uiView.text = text
    uiView.maxWidth = maxWidth
    uiView.fontSize = fontSizeOnMacCatalyst
  }
}

class MultilineTextView: UITextView {
  
  var maxWidth: CGFloat
  
  var fontSize: CGFloat {
    didSet {
      updateFont()
    }
  }
  
  init(frame: CGRect, textContainer: NSTextContainer? = nil, maxWidth: CGFloat = 0, fontSize: CGFloat = 17) {
    self.maxWidth = maxWidth
    self.fontSize = fontSize
    super.init(frame: frame, textContainer: textContainer)
    commonInit()
  }
  
  required init?(coder: NSCoder) {
    self.maxWidth = 0
    self.fontSize = 17
    super.init(coder: coder)
    commonInit()
  }
  
  private func updateFont() {
    #if targetEnvironment(macCatalyst)
    self.font = .systemFont(ofSize: fontSize)
    #else
    self.font = UIFont.preferredFont(forTextStyle: .body)
    #endif
  }
  
  private func commonInit() {
    self.updateFont()
    self.adjustsFontForContentSizeCategory = true
    self.isSelectable = true
    self.isScrollEnabled = false
    self.showsVerticalScrollIndicator = false
    self.showsHorizontalScrollIndicator = false
    self.textContainerInset = .zero
    self.textContainer.lineFragmentPadding = 0
    self.textColor = .label
    self.backgroundColor = .clear
    #if !os(tvOS)
    self.isEditable = false
    self.dataDetectorTypes = .all
    #endif
  }
  
  override var intrinsicContentSize: CGSize {
    let fittingSize = sizeThatFits(CGSize(width: maxWidth, height: 0))
    return CGSize(width: 0, height: fittingSize.height)
  }
}
