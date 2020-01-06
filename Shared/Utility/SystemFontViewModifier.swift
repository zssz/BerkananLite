//
//  Created by Zsombor Szabo on 03/01/2020.
//  Copyright © 2020 IZE. All rights reserved.
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
