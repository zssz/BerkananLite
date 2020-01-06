//
//  Created by Zsombor Szabo on 05/01/2020.
//  Copyright © 2020 IZE. All rights reserved.
//

import Foundation
import BerkananSDK

extension AppDelegate {
  
  var isScreenshoting: Bool {
//    return true
    return ProcessInfo.processInfo.arguments.contains("-ui_testing")
  }
  
  func prepareForScreenshots() {
    berkananBluetoothService.stop()
    userData.firstRun = false
    userData.termsAcceptButtonTapped = true
    userData.currentUserName = "John"
    userData.currentUserUUIDString = "90D8A7BE-006A-4A13-91CB-5D1902E1FDA4"
    userData.numberOfNearbyUsers = 3
    let john = User.current
    let kate = User.with {
      $0.identifier = UUID(uuidString: "ACDA73BA-0AE5-4C53-8B82-63AEDA49EDCF")!.protobufValue()
      $0.name = NSLocalizedString("Kate", comment: "")
    }
    let simone = User.with {
      $0.identifier = UUID(uuidString: "E3076E53-D82E-4E3F-948D-B52E6E62CA9B")!.protobufValue()
      $0.name = NSLocalizedString("Simone", comment: "")
    }
    let michael = User.with {
      $0.identifier = UUID(uuidString: "A393005A-9699-414E-8337-7BF32329195C")!.protobufValue()
      $0.name = NSLocalizedString("Michael", comment: "")
    }
    self.messageStore.insert(message: PublicMessage.with({
      $0.identifier = .random()
      $0.sourceUser = john
      $0.text = NSLocalizedString("Suggestions for a new TV series to watch? 🤔", comment: "Message used in app screenshots.")
    }), at: 0)
    self.messageStore.insert(message: PublicMessage.with({
      $0.identifier = .random()
      $0.sourceUser = kate
      $0.text = "Game of Thrones"
    }), at: 0)
    self.messageStore.insert(message: PublicMessage.with({
      $0.identifier = .random()
      $0.sourceUser = michael
      $0.text = "Rick and Morty 🤓"
    }), at: 0)
    self.messageStore.insert(message: PublicMessage.with({
      $0.identifier = .random()
      $0.sourceUser = simone
      $0.text = "Stranger Things!"
    }), at: 0)
  }  
}
