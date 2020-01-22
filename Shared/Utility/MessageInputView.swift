//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit

public class MessageInputView: UIView {
  
  @IBOutlet weak public var textField: UITextField!
  
  @IBOutlet weak public var sendButton: UIButton!
  
  @IBOutlet weak var visualEffectView: UIVisualEffectView!
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    self.textField.text = ""
    self.sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: UIControl.State())
    #if !os(tvOS)
    visualEffectView.effect = UIBlurEffect(style: .systemChromeMaterial)
    #else
    visualEffectView.effect = UIBlurEffect(style: .regular)
    #endif
    textField.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
  }
  
  override public var intrinsicContentSize: CGSize {
    return .zero
  }
}
