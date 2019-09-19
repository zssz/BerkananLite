//
//  Created by Zsombor Szabo on 19/09/2019.
//  Copyright © 2019 IZE. All rights reserved.
//

import SwiftUI

struct PrivacyView: View {
    var privacy: String {
        if let path = Bundle.main.path(forResource: "PrivacyPolicy", ofType: ".txt"), let text = try? String(contentsOfFile: path) {
            return text
        }
        return ""
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: true) {
            Text("TL;DR: We don't collect your personal information.").font(.headline).fixedSize(horizontal: false, vertical: true).padding()
            Text(privacy).fixedSize(horizontal: false, vertical: true).padding()
        }.navigationBarTitle(Text("Privacy Policy"))
    }
}

struct PrivacyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyView()
    }
}
