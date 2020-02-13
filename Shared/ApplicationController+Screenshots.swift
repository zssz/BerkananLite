//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import BerkananSDK
import SwiftUI

extension ApplicationController {
  
  var isScreenshoting: Bool {
//    return true
    return ProcessInfo.processInfo.arguments.contains("-ui_testing")
  }
  
  func prepareForScreenshots(animated:Bool = false) {
    self.berkananBluetoothService.stop()
    self.userData.firstRun = false
    self.userData.termsAcceptButtonTapped = true
    self.userData.numberOfNearbyUsers = 3
    self.userData.currentUserName = "John"
    self.userData.currentUserUUIDString = "90D8A7BE-006A-4A13-91CB-5D1902E1FDA4"
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
    //    for _ in 0...1000 {
    //      messageStore.insert(message: PublicMessage.with({
    //        $0.identifier = .random()
    //        $0.sourceUser = [john, kate, simone, michael].randomElement()!
    //        $0.text = String((0..<Int.random(in: 0..<140)).map{ _ in "abcdefghij klmnopqrst uvwxyzABCD EFGHIJKLMN OPQRSTUVW XYZ0123456789 🤓".randomElement()! })
    //      }), at: 0)
    //    }
    let messages: [PublicMessage] = [
      .with({
        $0.identifier = .random()
        $0.sourceUser = john
        $0.text = NSLocalizedString("Suggestions for a new TV series to watch? 🤔", comment: "Message used in app screenshots.")
      }),
      .with({
        $0.identifier = .random()
        $0.sourceUser = kate
        $0.text = "Stranger Things"
      }),
      .with({
        $0.identifier = .random()
        $0.sourceUser = michael
        $0.text = "Rick and Morty 🤓"
      }),
      .with({
        $0.identifier = .random()
        $0.sourceUser = simone
        $0.text = "The Mandalorian!"
      }),
    ]
    if animated {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
        withAnimation {
          self.messageStore.insert(message: messages[0], at: 0)
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
        withAnimation {
          self.messageStore.insert(message: messages[1], at: 0)
        }
      }
      DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
        withAnimation {
          self.messageStore.insert(message: messages[2], at: 0)
          self.messageStore.insert(message: messages[3], at: 0)
        }
      }
    }
    else {
      self.messageStore.messages = messages
    }
  }
}
