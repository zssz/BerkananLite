//
// Copyright © 2019 IZE Ltd. and the project authors
// Licensed under MIT License
//
// See LICENSE.txt for license information.
//

import Foundation
import SwiftUI

struct SystemFont: ViewModifier {
  var font: Font
  var sizeOnMacCatalyst: Binding<CGFloat>
  var weight: Font.Weight = .regular
  var design: Font.Design = .default
  
  func body(content: Content) -> some View {
    #if targetEnvironment(macCatalyst)
    return content.font(.system(size: sizeOnMacCatalyst.wrappedValue, weight: weight, design: design))
    #else
    return content.font(font)
    #endif
  }
}
