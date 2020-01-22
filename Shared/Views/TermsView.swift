//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import SwiftUI

struct TermsView: View {
  
  var text: String {
    if let path = Bundle.main.path(forResource: "TermsOfUse", ofType: ".txt"), let text = try? String(contentsOfFile: path) {
      return text
    }
    return ""
  }
  
  var body: some View {
    ScrollView(.vertical, showsIndicators: true) {
      VStack(alignment: .leading) {
        Text("Be a good person. Please don't post objectionable content and don't be abusive.").font(.headline)
        Spacer()
        Text(verbatim: self.text)
      }.padding()
    }.navigationBarTitle(Text("Terms of Use"))
  }
}

struct TermsView_Previews: PreviewProvider {
  static var previews: some View {
    TermsView()
  }
}
