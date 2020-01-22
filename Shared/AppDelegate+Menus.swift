//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import UIKit

extension AppDelegate {
  
  override func buildMenu(with builder: UIMenuBuilder) {
    if builder.system == .main {
      self.menuController = MenuController(with: builder)
    }
  }
  
  override func validate(_ command: UICommand) {
    if command.action == #selector(makeTextSmaller) {
      command.attributes = (ApplicationController.shared.userData.bodyFontSize > UserData.minimumBodyFontSize) ? [] : .disabled
    }
    else if command.action == #selector(showPreferences) {
      command.attributes = (ApplicationController.shared.userData.showsPreferences) ? .disabled : []
    }
  }
  
  @objc public func makeTextBigger() {
    ApplicationController.shared.userData.bodyFontSize += 2
  }
  
  @objc public func makeTextSmaller() {
    ApplicationController.shared.userData.bodyFontSize -= 2
  }
  
  @objc public func showPreferences() {
    ApplicationController.shared.userData.showsPreferences = true
  }
}
