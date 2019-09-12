//
//  Created by Zsombor Szabo on 14/06/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import SwiftUI
import BerkananSDK

struct MessageRow : View {
    
    var message: PublicBroadcastMessage
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(message.sourceUser.displayName).font(.headline).lineLimit(nil)
            Text(message.text ?? "").font(.subheadline).lineLimit(nil)
        }
    }
}

#if DEBUG
struct MessageRow_Previews : PreviewProvider {
    static var previews: some View {
        Group {
            MessageRow(message: PublicBroadcastMessage(text: "Hello!")).previewLayout(.fixed(width: 300, height: 70))
            MessageRow(message: PublicBroadcastMessage(text: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")).previewLayout(.fixed(width: 300, height: 70))
        }
    }
}
#endif
