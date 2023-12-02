//
//  SimulationView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

struct SimulationView: View {
    var body: some View {
        Canvas(rendersAsynchronously: false) { context, size in
            let origin = CGPoint(x: size.width/2.0, y: size.height/2.0)
            let path = Path(ellipseIn: CGRect(origin: origin, size: size))
            context.stroke(path, with: .color(.green), lineWidth: 4)
        }
        .background(.gray)
    }
}

#Preview {
    SimulationView()
}
