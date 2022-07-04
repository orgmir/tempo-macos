//
//  ClockView.swift
//  Tempo
//
//  Created by Luis Ramos on 16/10/20.
//

import SwiftUI

class ClockState: ObservableObject {
    @Published var timeString = "10 30"
}

struct ClockView: View {
    @ObservedObject var state = ClockState()

    var body: some View {
        Text(state.timeString)
            .font(Font.system(size: 40).bold())
            .foregroundColor(.white)
            .padding(6)
            .background(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color(hue: 0.85, saturation: 0, brightness: 0.9), lineWidth: 4)
            )
    }
}

struct ClockView_Previews: PreviewProvider {
    static var previews: some View {
        ClockView()
    }
}
