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
    
    // move particle around with drag gesture
    @State private var dragging = false
    @State private var location = CGPoint.zero
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { self.dragging = true; self.location = $0.location }
            .onEnded { _ in self.dragging = false }
    }
    
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
            
            if (dragging) {
                let gradient = Gradient(colors: [.red.opacity(0.3), .clear])
                let d = 25.0*thickness, location = location.applying(context.transform.inverted())
                let cursor = Path(ellipseIn: CGRect(x: location.x-d/2.0, y: location.y-d/2.0, width: d, height: d))
                context.fill(cursor, with: .radialGradient(gradient, center: location, startRadius: 0.0, endRadius: d/2.0))
            }

        }
        .background(.gray)
        .gesture(drag)
    }
}

#Preview {
    SimulationView()
}
