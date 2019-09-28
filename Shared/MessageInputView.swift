//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit
import Combine
import BerkananSDK

public class MessageInputView: UIView {
  
  @IBOutlet weak public var textField: UITextField!
  
  @IBOutlet weak public var sendButton: UIButton!
  
  @IBOutlet weak var visualEffectView: UIVisualEffectView!
  
  private var textDidChangeNotificationCanceller: AnyCancellable?
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    self.textField.text = NSLocalizedString("Hello!", comment: "")
    self.sendButton.setTitle(NSLocalizedString("Send", comment: ""), for: UIControl.State())
    visualEffectView.effect = UIBlurEffect(style: .systemChromeMaterial)
    textField.topAnchor.constraint(equalTo: topAnchor, constant: 5.0).isActive = true
    textDidChangeNotificationCanceller = NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: textField).sink { [weak self] notification in
      guard let self = self else { return }
      self.textField.textColor = PublicBroadcastMessage.isPDUTooBig(for: self.textField.text ?? "") ? .systemRed : .label
      self.sendButton.isHidden = self.textField.text?.isEmpty ?? true
      self.setNeedsLayout()
      UIView.animate(withDuration: 0.2) {
        self.layoutIfNeeded()
      }
    }
  }
  
  override public var intrinsicContentSize: CGSize {
    return .zero
  }    
}
