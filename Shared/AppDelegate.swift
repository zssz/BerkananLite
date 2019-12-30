//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit
import BerkananSDK
import Combine
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  static let berkananLiteServiceConfigurationIdentifier = UUID(uuidString: "A59240D8-26DF-47C5-A3A7-CC2B5DEB8919")!
  
  public var berkananBluetoothService = try! BerkananBluetoothService(configuration: Configuration(identifier: berkananLiteServiceConfigurationIdentifier))
  
  public var messageStore = MessageStore()
  
  var receiveMessageCanceller: AnyCancellable?
  var numberOfNearbyUsersCanceller: AnyCancellable?
  var nearbyServicesObservation: NSKeyValueObservation?
  
  var userData = UserData()
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    if userData.firstRun {
      userData.firstRun = false
    }
    else {
      setupTerms()
      berkananBluetoothService.start()
    }
    
    /*
    do {
      // Initializing a local service with a configuration to advertise
      let configuration = Configuration(
        identifier: UUID(),
        userInfo: "My User Info".data(using: .utf8)!
      )
      let service = try BerkananBluetoothService(configuration: configuration)
      
      // Starting a local service
      service.start()
      
      // Discovering remote services and examining their configuration
      let discoverServiceCanceller = service.discoverServiceSubject
        .receive(on: RunLoop.main)
        .sink { service in
          print("Discovered \(service) with \(service.getConfiguration())")
      }
      
      // Constructing a message with a payload type identifier and payload
      let message = Message(
        payloadType: UUID(uuidString: "E268F3C1-5ADB-4412-BE04-F4A04F9B3D1A")!,
        payload: "Hello, World!".data(using: .utf8)
      )
      
      // Sending a message
      try service.send(message)
      
      // Receiving messages
      let receiveMessageCanceller = service.receiveMessageSubject
        .receive(on: RunLoop.main)
        .sink { message in
          print("Received \(message.payloadType) \(message.payload)")
      }
    }
    catch {
    }
 */
 
    receiveMessageCanceller = berkananBluetoothService.receiveMessageSubject
    .sink { message in
      switch message.payloadType {
        
        case .publicMessage:
          guard let publicMessage = try? PublicMessage(serializedData: message.payload) else { return }
          DispatchQueue.main.async {
            
            guard !self.userData.isBlocked(user: publicMessage.sourceUser) else { return }
            self.messageStore.insert(message: publicMessage, at: 0)
            
            // Notify user if needed
            // Only post notification if the app is in the background
            guard UIApplication.shared.applicationState == .background else { return }
            // Don't post notification for messages sent by current user
            guard publicMessage.sourceUser != User.current else { return }
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
              DispatchQueue.main.async {
                self.userData.notificationsAuthorizationStatus = settings.authorizationStatus
                // Don't post notification if user can't see it
                guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
                UNUserNotificationCenter.current().add(UNNotificationRequest(publicMessage: publicMessage), withCompletionHandler: nil)
              }
            })
          }
        
        default: ()
      }
    }
    setupUserNotifications()
    setupApplicationIconBadgeNumber()
    setupCurrentUserNameAndIdentifier()
    return true
  }
  
  private func setupTerms() {
    userData.termsNotAccepted = !userData.termsAcceptButtonTapped
  }
  
  private func setupCurrentUserNameAndIdentifier() {
    User.current.name = userData.currentUserName
    User.current.identifier = UUID(uuidString: userData.currentUserUUIDString)?.protobufValue() ?? PBUUID.random()
  }
  
  private func setupUserNotifications() {
    configureCurrentUserNotificationCenter()
    requestUserNotificationAuthorization(provisional: true)
  }
  
  /// Configures application icon badge number to show number of nearby users
  private func setupApplicationIconBadgeNumber() {
    UIApplication.shared.applicationIconBadgeNumber = berkananBluetoothService.servicesInRange.count
    numberOfNearbyUsersCanceller = berkananBluetoothService.publisher(for: \.servicesInRange)
    .receive(on: RunLoop.main)
    .sink(receiveValue: { (value) in
      let number = value.count
      UIApplication.shared.applicationIconBadgeNumber = number
      UIApplication.shared.connectedScenes.forEach { (scene) in
        guard let window = (scene.delegate as? UIWindowSceneDelegate)?.window else { return }
        guard let messagesViewController = window?.rootViewController as? MessagesViewController else { return }
        messagesViewController.messageInputView?.textField.placeholder = String.localizedStringWithFormat(NSLocalizedString("Message for %u nearby users", comment: ""), number)
      }
    })
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }
  
  // MARK: UISceneSession Lifecycle
  
  func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }
  
  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
  }
}
