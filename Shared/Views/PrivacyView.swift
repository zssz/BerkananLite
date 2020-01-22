//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct PrivacyView: View {
  
  var text: String {
    if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: ".txt"), let text = try? String(contentsOfFile: path) {
      return text
    }
    return ""
  }
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack(alignment: .leading) {
        Text("We don't collect your personal information.").font(.headline)
        Spacer()
        Text(verbatim: self.text)
      }.padding()
    }.navigationBarTitle(Text("Privacy Policy"))
  }
}

struct PrivacyView_Previews: PreviewProvider {
  static var previews: some View {
    PrivacyView()
  }
}
