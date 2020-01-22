//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import BerkananSDK
import Combine
import SwiftUI
#if os(watchOS)
import WatchKit
#else
import StoreKit
import UIKit
#endif

public class ApplicationController: NSObject {
  
  public static let shared: ApplicationController = ApplicationController()
  
  static let berkananLiteServiceConfigurationIdentifier = UUID(uuidString: "A59240D8-26DF-47C5-A3A7-CC2B5DEB8919")!
  
  public var berkananBluetoothService = try! BerkananBluetoothService(configuration: Configuration(identifier: berkananLiteServiceConfigurationIdentifier))
  
  var messageStore = MessageStore()    
  var userData = UserData()
  
  var numberOfSentMessages = 0
  var receiveMessageCanceller: AnyCancellable?
  var servicesInRangeCanceller: AnyCancellable?
  
  override init() {
    super.init()
    
    User.current.name = self.userData.currentUserName
    User.current.identifier = UUID(uuidString: self.userData.currentUserUUIDString)?.protobufValue() ?? .random()
    
    self.requestUserNotificationAuthorization(provisional: true)
    
    self.receiveMessageCanceller = self.berkananBluetoothService.receiveMessageSubject
      .sink { message in
        switch message.payloadType {
          
          case .publicMessage:
            guard let publicMessage = try? PublicMessage(serializedData: message.payload) else { return }
            DispatchQueue.main.async {
              guard !self.userData.isBlocked(user: publicMessage.sourceUser) else { return }
              #if os(watchOS)
              withAnimation { self.messageStore.insert(message: publicMessage, at: 0) }
              #else
              self.messageStore.insert(message: publicMessage, at: 0)
              #endif
              self.postUserNotificationIfNeeded(for: publicMessage)
          }
          
          default: ()
        }
    }
    
    self.servicesInRangeCanceller = self.berkananBluetoothService.publisher(for: \.servicesInRange)
      .receive(on: RunLoop.main)
      .sink(receiveValue: { (value) in
        let number = value.count
        if !self.isScreenshoting {
          self.userData.numberOfNearbyUsers = number
        }
        #if os(watchOS)
        #else
        UIApplication.shared.applicationIconBadgeNumber = number
        #endif
      })    
  }
  
  public func isMessageTooLong(for text: String) -> Bool {
    let publicMessage = PublicMessage(text: text)
    let payload = (try? publicMessage.serializedData()) ?? Data()
    let message = Message(payloadType: .publicMessage, payload: payload)
    let isPDUTooBig = message.isPDUTooBig()
    return isPDUTooBig
  }
  
  public func send(_ text: String) {
    do {
      let service = self.berkananBluetoothService
      let status = service.bluetoothAuthorization
      
      if status == .denied {
        throw ApplicationError.bluetoothPermissionDenied
      } else if status == .restricted {
        throw ApplicationError.bluetoothPermissionRestricted
      }
      
      guard service.servicesInRange.count > 0 else {
        throw ApplicationError.noNearbyUsers
      }
      
      guard !self.isMessageTooLong(for: text) else {
        throw ApplicationError.messageTooLong
      }
      
      let publicMessage = PublicMessage(text: text)
      let payload = try publicMessage.serializedData()
      let message = Message(payloadType: .publicMessage, payload: payload)
      service.receiveMessageSubject.send(message)
      try service.send(message)
      
      self.userData.composedText = ""
      
      // StoreKit
      self.numberOfSentMessages += 1
      if self.numberOfSentMessages == 4 {
        // User is delighted. We will ask for review now.
        #if !os(tvOS) && !os(watchOS)
        SKStoreReviewController.requestReviewForCurrentVersionIfNeeded()
        #endif
        // Bug workaround for disappearing keyboard after presenting review request alert
        #if !targetEnvironment(macCatalyst) && !os(watchOS)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
          if let rootViewController = (UIApplication.shared.connectedScenes.first { $0.delegate is UIWindowSceneDelegate }?.delegate as? UIWindowSceneDelegate)?.window??.rootViewController {
            rootViewController.becomeFirstResponder()
            rootViewController.reloadInputViews()
          }
        }
        #endif
      }
    }
    catch {
      self.present(error: error as NSError)
    }
  }
}


