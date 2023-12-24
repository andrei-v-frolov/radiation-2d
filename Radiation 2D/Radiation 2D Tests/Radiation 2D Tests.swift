//
//  Radiation_2DTests.swift
//  Radiation 2DTests
//
//  Created by Andrei Frolov on 2023-12-01.
//

import XCTest

final class RadiationTests: XCTestCase {
    override func setUpWithError() throws { super.setUp() }
    override func tearDownWithError() throws { super.tearDown() }
    
    // test tolerance
    let epsilon: Double = 3.0e-15
    
    // test particle motion integrator
    func testParticle() throws {
        let alpha = 1.0, dt = 1.0/alpha
        
        for i in 1...20 {
            let psi = Double(i)/10.0, p = sinh(psi), x = -psi/alpha
            var particle = Particle(state: SIMD4<Double>(x,0,p,0))
            
            // compare against exact solution
            for t in stride(from: 0.0, through: 10.0*dt, by: dt) {
                XCTAssertEqual(particle.p.x, p*exp(-alpha*t), accuracy: epsilon)
                XCTAssertEqual(particle.x.x, -asinh(p*exp(-alpha*t))/alpha, accuracy: epsilon)
                particle.advance(dt, steps: 10)
            }
        }
    }
}
