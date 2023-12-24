//
//  ContentView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack(alignment: .top) {
            TimelineView(.animation) { timeline in SimulationView(time: timeline.date.timeIntervalSinceReferenceDate) }
            TrajectoryView().frame(maxWidth: .infinity).background(.ultraThinMaterial)
        }
        .padding(0)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
