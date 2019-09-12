//
//  Created by Zsombor Szabo on 10/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import UIKit
import BerkananSDK
import Combine
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    public var berkananNetwork = BerkananNetwork.shared
    
    var publicBroadcastMessageSubjectCanceller: AnyCancellable?
    var numberOfNearbyUsersCanceller: AnyCancellable?
    
    var userData = UserData()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.        
        BerkananNetwork.shared.start()
        setupUserNotifications()
        setupApplicationIconBadgeNumber()
        return true
    }
    
    private func setupUserNotifications() {
        configureCurrentUserNotificationCenter()
        requestUserNotificationAuthorization(provisional: true)
        publicBroadcastMessageSubjectCanceller = berkananNetwork.publicBroadcastMessageSubject
            .receive(on: RunLoop.main)
            .sink { message in
                UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { (settings) in
                    DispatchQueue.main.async {
                        // Don't post notification if user can't see it
                        guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
                        // Only post notification if the app is in the background
                        guard UIApplication.shared.applicationState == .background else { return }
                        // Don't post notification for messages sent by current user
                        guard message.sourceUser != User.current else { return }
                        UNUserNotificationCenter.current().add(UNNotificationRequest(publicBroadcastMessage: message), withCompletionHandler: nil)
                    }
                })
        }
    }
    
    /// Configures application icon badge number to show number of nearby users
    private func setupApplicationIconBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = berkananNetwork.numberOfNearbyUsers
        numberOfNearbyUsersCanceller = berkananNetwork.publisher(for: \.numberOfNearbyUsers)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { (value) in
                UIApplication.shared.applicationIconBadgeNumber = value
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
