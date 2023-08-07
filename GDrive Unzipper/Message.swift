//
//  Message.swift
//  GDrive Unzipper
//
//  Created by Tuan on 02/08/2023.
//

import SwiftUI

struct MessageState {
    var message: String
    var show: Bool
}

struct Message: View {
    @Binding public var state: MessageState
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle")
            Text(state.message)
        }.padding(10).background(Color.red).cornerRadius(8).padding(.bottom, 10).onAppear(perform: delayDisappear).onTapGesture(perform: delayDisappear)
    }
    private func delayDisappear() {
          // Delay of 7.5 seconds (1 second = 1_000_000_000 nanoseconds)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            
            state.show = false
            print("disappear")

        }
    }
}

struct Message_Previews: PreviewProvider {
    static var previews: some View {
        Message(state: .constant(MessageState(message: "", show: true)))
    }
}
