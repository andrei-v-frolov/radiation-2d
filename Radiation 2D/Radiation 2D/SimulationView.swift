//
//  SimulationView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

struct SimulationView: View {
    @State private var trajectory: Trajectory = .racetrack(3.0)
    var time: Double = 0.0
    
    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let scale = min(size.width, size.height)/10.0, thickness = 4.0/scale
            context.translateBy(x: size.width/2.0, y: size.height/2.0)
            context.scaleBy(x: scale, y: -scale)
            
            if let trajectory = trajectory.path {
                context.stroke(trajectory, with: .color(.green), lineWidth: thickness)
            }
            
            let v = trajectory.state(at: time)
            context.stroke(Path { $0.move(to: CGPoint(v.q)); $0.addLine(to: CGPoint(v.q+v.p))}, with: .color(.orange), lineWidth: thickness)
            context.fill(Symbol.circle.shape(at: v.xy, size: 5.0*thickness), with: .color(.red))
        }
        .background(.gray)
    }
}

#Preview {
    SimulationView()
}
