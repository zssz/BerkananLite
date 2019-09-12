//
//  Created by Zsombor Szabo on 15/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import BerkananSDK

class MessageStore : ObservableObject {
    
    private static let maxNumbferOfMessages: Int = 1024
    
    @Published var messages: [PublicBroadcastMessage] = []
    
    private var publicBroadcastMessageSubjectCanceller: AnyCancellable?
    
    init(messages: [PublicBroadcastMessage] = []) {
        self.messages = messages
        if let network = (UIApplication.shared.delegate as? AppDelegate)?.berkananNetwork {
            publicBroadcastMessageSubjectCanceller = network.publicBroadcastMessageSubject
                .receive(on: RunLoop.main)
                .sink { [weak self] message in
                    guard let self = self else { return }
                    self.insert(message: message, at: 0)
            }
        }
    }
    
    public func clear() {
        self.messages = []
    }
    
    public func insert(message: PublicBroadcastMessage, at index: Int) {
        if self.messages.count >= MessageStore.maxNumbferOfMessages {
            self.messages.remove(at: self.messages.count-1)
        }
        self.messages.insert(message, at: index)
    }
    
    public func remove(at offsets: IndexSet) {
        offsets.reversed().forEach { index in
            self.messages.remove(at: index)
        }        
    }
}
