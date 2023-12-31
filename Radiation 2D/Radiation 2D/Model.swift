//
//  Model.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import simd
import SwiftUI

// pre-defined charge symbols
enum Symbol {
    case circle
    
    // path outlining charge symbol
    func shape(at v: SIMD2<Double>, size: Double) -> Path {
        switch self {
            default: return Path(ellipseIn: CGRect(x: v.x-size/2.0, y: v.y-size/2.0, width: size, height: size))
        }
    }
}

// pre-defined charge trajectories
enum Trajectory: CaseIterable, Hashable {
    case drag, line(Double), dipole, circle, racetrack(Double)
    
    // cases exposed to UI
    static var allCases: [Self] = [.drag, .line(7.0), .dipole, .circle, .racetrack(3.0)]
    
    // text description
    var description: String {
        switch self {
            case .drag: return "Drag Freely"
            case .line: return "Straight Line"
            case .dipole: return "Dipole"
            case .circle: return "Synchrotron"
            case .racetrack: return "Race Track"
        }
    }
    
    // total length of the trajectory
    var length: Double {
        switch self {
            case .drag: return 0.0
            case .line(let w): return w
            case .dipole: return 4.0
            case .circle: return 2.0*Double.pi
            case .racetrack(let w): return 2.0*(w + Double.pi)
        }
    }
    
    // path tracing the trajectory
    var path: Path? {
        switch self {
            case .drag: return nil
            case .line(let w): return Path {
                $0.move(to: CGPoint(x: -w/2.0, y: 0.0))
                $0.addLine(to: CGPoint(x: w/2.0, y: 0.0))
            }
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
    
    // position and velocity along the trajectory
    func state(at l: Double) -> SIMD4<Double> {
        let l = l.truncatingRemainder(dividingBy: length)
        
        switch self {
            case .drag:
                return SIMD4<Double>.zero
            case .line(let w):
                return  SIMD4<Double>(l-w/2.0, 0.0, 1.0, 0.0)
            case .dipole:
                let phi = (Double.pi/2.0) * l
                return  SIMD4<Double>(0.0, sin(phi), 0.0, cos(phi))
            case .circle:
                let c = cos(l), s = sin(l)
                return SIMD4<Double>(s, c, c, -s)
            case .racetrack(let w):
                if (l < w) {
                    return SIMD4<Double>(l-w/2.0, 1.0, 1.0, 0.0)
                } else if (l < w + Double.pi) {
                    let c = cos(l-w), s = sin(l-w)
                    return SIMD4<Double>(s+w/2.0, c, c, -s)
                } else if (l < 2.0*w + Double.pi) {
                    return SIMD4<Double>(Double.pi+1.5*w - l, -1.0, -1.0, 0.0)
                } else {
                    let c = cos(l-2.0*w), s = sin(l-2.0*w)
                    return SIMD4<Double>(s-w/2.0, c, c, -s)
                }
        }
    }
}

// relativistic particle
struct Particle {
    // integrator state
    var state = SIMD4<Double>(repeating: 0.0)
    
    // coordinates and momentum
    var x: SIMD2<Double> { state.lowHalf }
    var p: SIMD2<Double> { state.highHalf }
    var v: SIMD2<Double> { p/sqrt(1.0+dot(p,p)) }
    
    // relativistic equations of motion
    mutating func advance(_ dt: Double, follow: SIMD2<Double>? = nil, steps n: Int = 1) {
        let alpha = 1.0, kappa = 1.0
        
        if let t = follow {
            // damped oscillator
            for _ in 0..<n {
                state = gl8(state: state, step: dt/Double(n)) {
                    let x = $0.lowHalf, p = $0.highHalf, v = p/sqrt(1.0+dot(p,p))
                    return SIMD4<Double>(lowHalf: v, highHalf: -alpha*p - kappa*(x-t))
                }
            }
        } else {
            // damped motion
            for _ in 0..<n {
                state = gl8(state: state, step: dt/Double(n)) {
                    let p = $0.highHalf, v = p/sqrt(1.0+dot(p,p))
                    return SIMD4<Double>(lowHalf: v, highHalf: -alpha*p)
                }
            }
        }
    }
}
