//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct HostingControllerView: View {  
  var body: some View {
    return ContentView(messageStore: ApplicationController.shared.messageStore).environmentObject(ApplicationController.shared.userData)
  }
}
