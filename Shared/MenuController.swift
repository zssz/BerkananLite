//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit

class MenuController {
  
  init(with builder: UIMenuBuilder) {
    builder.remove(menu: .format)
    builder.insertSibling(MenuController.preferencesMenu(), afterMenu: .about)
    builder.insertChild(MenuController.adjustTextSizeMenu(), atStartOfMenu: .view)
  }
  
  class func preferencesMenu() -> UIMenu {
    let showPreferencesCommand =
      UIKeyCommand(title: NSLocalizedString("Preferences...", comment: ""),
                   image: nil,
                   action: #selector(AppDelegate.showPreferences),
                   input: ",",
                   modifierFlags: .command,
                   propertyList: nil)
    let preferencesMenu =
      UIMenu(title: "",
             image: nil,
             identifier: UIMenu.Identifier("company.ize.BerkananLite.menus.preferences"),
             options: .displayInline,
             children: [showPreferencesCommand])
    return preferencesMenu
  }
  
  class func adjustTextSizeMenu() -> UIMenu {
    let makeTextBiggerCommand =
      UIKeyCommand(title: NSLocalizedString("Make Text Bigger", comment: ""),
                   image: nil,
                   action: #selector(AppDelegate.makeTextBigger),
                   input: "+",
                   modifierFlags: .command,
                   propertyList: nil)
    let makeTextSmallerCommand =
      UIKeyCommand(title: NSLocalizedString("Make Text Smaller", comment: ""),
                   image: nil,
                   action: #selector(AppDelegate.makeTextSmaller),
                   input: "-",
                   modifierFlags: .command,
                   propertyList: nil)
    let adjustTextSizeMenu =
      UIMenu(title: "",
             image: nil,
             identifier: UIMenu.Identifier("company.ize.BerkananLite.menus.adjustTextSizeMenu"),
             options: .displayInline,
             children: [makeTextBiggerCommand, makeTextSmallerCommand])
    return adjustTextSizeMenu
  }
}
