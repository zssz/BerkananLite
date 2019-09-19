//
//  Created by Zsombor Szabo on 18/09/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import Foundation

extension Bundle {
    
    public var shortVersion: String {
        return object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
    }
    
    public var bundleVersion: String {
        return object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
    }
    
    public var formattedVersion: String {
        return shortVersion + " (" + bundleVersion + ")"
    }
}
