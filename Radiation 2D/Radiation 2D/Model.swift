//
//  Model.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

// pre-defined charge trajectories
enum Trajectory {
    case dipole, circle, racetrack(Double)
    
    // total length of the trajectory
    var length: Double {
        switch self {
            case .dipole: return 4.0
            case .circle: return 2.0*Double.pi
            case .racetrack(let w): return 2.0*(w + Double.pi)
        }
    }
    
    // path tracing the trajectory
    var path: Path {
        switch self {
            case .dipole: return Path {
                $0.move(to: CGPoint(x: 0.0, y: -1.0))
                $0.addLine(to: CGPoint(x: 0.0, y: 1.0))
            }
            case .circle: return Path(ellipseIn: CGRect(x: -1.0, y: -1.0, width: 2.0, height: 2.0))
            case .racetrack(let w): return Path {
                let nw = CGPoint(x: -w/2.0, y:  1.0), ne = CGPoint(x: w/2.0, y:  1.0)
                let sw = CGPoint(x: -w/2.0, y: -1.0), se = CGPoint(x: w/2.0, y: -1.0)
                let phi = Angle(degrees: 90)
                
                $0.move(to:nw)
                $0.addLine(to: ne)
                $0.addArc(center: (ne+se)/2, radius: 1.0, startAngle: phi, endAngle: -phi, clockwise: true)
                $0.addLine(to: sw)
                $0.addArc(center: (nw+sw)/2, radius: 1.0, startAngle: -phi, endAngle: phi, clockwise: true)
            }
        }
    }
}
