//
//  AboutView.swift
//  GDrive Unzipper
//
//  Created by Tuan on 02/08/2023.
//

import SwiftUI

struct AboutView: View {
    var body: some View {
          VStack {
              Spacer()
              HStack {
                  Spacer()
                  Text("Hello, World!")
                  Spacer()
              }
              Spacer()
          }
          .frame(minWidth: 300, minHeight: 300)
      }
}

struct AboutView_Previews: PreviewProvider {
    static var previews: some View {
        AboutView()
    }
}
