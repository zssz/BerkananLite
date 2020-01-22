//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import UIKit
import BerkananSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    if ApplicationController.shared.userData.firstRun {
      ApplicationController.shared.userData.firstRun = false
    }
    else {
      ApplicationController.shared.userData.termsNotAccepted = !ApplicationController.shared.userData.termsAcceptButtonTapped
      ApplicationController.shared.berkananBluetoothService.start()
    }
    if ApplicationController.shared.isScreenshoting {
      ApplicationController.shared.prepareForScreenshots()
    }
       
    return true
  }
  
  private func frameworkTest() {
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
  
  // MARK: - Menus
    
  #if !os(tvOS)
  var menuController: MenuController!
  #endif
  
}
