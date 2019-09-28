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
      Text("TL;DR: Be a good person. Please don't post objectionable content and don't be abusive.").font(.headline).fixedSize(horizontal: false, vertical: true).padding()
      Text(text).fixedSize(horizontal: false, vertical: true).padding()
    }.navigationBarTitle(Text("Terms of Use"))
  }
}

struct TermsView_Previews: PreviewProvider {
  static var previews: some View {
    TermsView()
  }
}
