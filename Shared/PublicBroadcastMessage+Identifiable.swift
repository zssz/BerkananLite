//
//  Created by Zsombor Szabo on 18/09/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import Foundation
import BerkananSDK

extension PublicBroadcastMessage: Identifiable {
    
    public var id: UUID? {
        return uuid
    }    
}
