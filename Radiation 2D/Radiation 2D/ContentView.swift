//
//  ContentView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            SimulationView()
        }
        .padding(0)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
