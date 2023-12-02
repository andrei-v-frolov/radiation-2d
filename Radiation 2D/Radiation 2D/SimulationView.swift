//
//  SimulationView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

struct SimulationView: View {
    @State private var trajectory: Trajectory = .racetrack(2.0)
    
    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let scale = min(size.width, size.height)/10.0, thickness = 4.0/scale
            context.translateBy(x: size.width/2.0, y: size.height/2.0)
            context.scaleBy(x: scale, y: -scale)
            
            context.stroke(trajectory.path, with: .color(.green), lineWidth: thickness)
        }
        .background(.gray)
    }
}

#Preview {
    SimulationView()
}
