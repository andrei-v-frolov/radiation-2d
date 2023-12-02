//
//  CG Math Tests.swift
//  Radiation 2D Tests
//
//  Created by Andrei Frolov on 2023-12-01.
//

import Foundation
import XCTest

final class CGMathTests: XCTestCase {
    override func setUpWithError() throws { super.setUp() }
    override func tearDownWithError() throws { super.tearDown() }

    // test tolerance
    let epsilon: CGFloat = 3.0e-15
    
    // randomized vectors and transforms
    var random: CGFloat { return Double.random(in: -Double.pi...Double.pi) }
    var point: CGPoint { return CGPoint(x: random, y: random) }
    var size: CGSize {  return CGSize(width: random, height: random) }
    var R: CGAffineTransform { return CGAffineTransform(rotationAngle: random) }
    var S: CGAffineTransform { return CGAffineTransform(scaleX: random, y: random) }
    var T: CGAffineTransform { return CGAffineTransform(translationX: random, y: random) }
    
    func testInitializers() throws {
        // uniform scaling
        let s = random, A = CGAffineTransform(scale: s)
        XCTAssertEqual(A.a, s)
        XCTAssertEqual(A.d, s)
        XCTAssertEqual(A.b, 0.0)
        XCTAssertEqual(A.c, 0.0)
        XCTAssertEqual(A.tx,0.0)
        XCTAssertEqual(A.ty,0.0)
        
        // translation by vector
        let p = point, B = CGAffineTransform(shift: p)
        XCTAssertEqual(B.a, 1.0)
        XCTAssertEqual(B.d, 1.0)
        XCTAssertEqual(B.b, 0.0)
        XCTAssertEqual(B.c, 0.0)
        XCTAssertEqual(B.tx,p.x)
        XCTAssertEqual(B.ty,p.y)
        
        // translation by vector, CGSize flavour
        let q = size, C = CGAffineTransform(shift: q)
        XCTAssertEqual(C.a, 1.0)
        XCTAssertEqual(C.d, 1.0)
        XCTAssertEqual(C.b, 0.0)
        XCTAssertEqual(C.c, 0.0)
        XCTAssertEqual(C.tx,q.width)
        XCTAssertEqual(C.ty,q.height)
    }
    
    func testCompositionOrder() throws {
        let A = S, B = T, P = A*B, Q = B*A
        
        // scale then translate
        XCTAssertEqual(P.a, A.a)
        XCTAssertEqual(P.d, A.d)
        XCTAssertEqual(P.b, 0.0)
        XCTAssertEqual(P.c, 0.0)
        XCTAssertEqual(P.tx,B.tx)
        XCTAssertEqual(P.ty,B.ty)
        
        // translate then scale
        XCTAssertEqual(Q.a, A.a)
        XCTAssertEqual(Q.d, A.d)
        XCTAssertEqual(Q.b, 0.0)
        XCTAssertEqual(Q.c, 0.0)
        XCTAssertEqual(Q.tx,A.a*B.tx)
        XCTAssertEqual(Q.ty,A.d*B.ty)
    }
    
    func testScaling() throws {
        // uniform scaling
        let s = random, A = CGAffineTransform(scale: s), Q = R*S*R*T
        
        // right scaling
        let Qs = Q*s, QS = Q*A
        XCTAssertEqual(Qs.a, QS.a)
        XCTAssertEqual(Qs.b, QS.b)
        XCTAssertEqual(Qs.c, QS.c)
        XCTAssertEqual(Qs.d, QS.d)
        XCTAssertEqual(Qs.tx, QS.tx)
        XCTAssertEqual(Qs.ty, QS.ty)
        
        // left scaling
        let sQ = s*Q, SQ = A*Q
        XCTAssertEqual(sQ.a, SQ.a)
        XCTAssertEqual(sQ.b, SQ.b)
        XCTAssertEqual(sQ.c, SQ.c)
        XCTAssertEqual(sQ.d, SQ.d)
        XCTAssertEqual(sQ.tx, SQ.tx)
        XCTAssertEqual(sQ.ty, SQ.ty)
    }
    
    func testPointScaling() throws {
        // scaling CGPoint vectors
        let s = random, p = point, P = CGAffineTransform(shift: p)
        let A = CGAffineTransform(scale: s), B = CGAffineTransform(scale: 1.0/s)
        let PA = (P*A).shift, PB = (P*B).shift
        
        XCTAssertEqual((p*s).x, PA.x, accuracy: epsilon)
        XCTAssertEqual((p*s).y, PA.y, accuracy: epsilon)
        XCTAssertEqual((p/s).x, PB.x, accuracy: epsilon)
        XCTAssertEqual((p/s).y, PB.y, accuracy: epsilon)
    }
    
    func testSizeScaling() throws {
        // scaling CGSize vectors
        let s = random, q = size, Q = CGAffineTransform(shift: q)
        let A = CGAffineTransform(scale: s), B = CGAffineTransform(scale: 1.0/s)
        let QA = (Q*A).size, QB = (Q*B).size
        
        XCTAssertEqual((q*s).width, QA.width, accuracy: epsilon)
        XCTAssertEqual((q*s).height, QA.height, accuracy: epsilon)
        XCTAssertEqual((q/s).width, QB.width, accuracy: epsilon)
        XCTAssertEqual((q/s).height, QB.height, accuracy: epsilon)
    }
    
    func testTranslation() throws {
        // translation
        let p = point, A = CGAffineTransform(shift: p), Q = R*S*R*T
        
        // transform then translate
        let Qp = Q+p, QP = Q*A
        XCTAssertEqual(Qp.a, QP.a, accuracy: epsilon)
        XCTAssertEqual(Qp.b, QP.b, accuracy: epsilon)
        XCTAssertEqual(Qp.c, QP.c, accuracy: epsilon)
        XCTAssertEqual(Qp.d, QP.d, accuracy: epsilon)
        XCTAssertEqual(Qp.tx, QP.tx, accuracy: epsilon)
        XCTAssertEqual(Qp.ty, QP.ty, accuracy: epsilon)
        
        // translate then transform
        let pQ = p+Q, PQ = A*Q
        XCTAssertEqual(pQ.a, PQ.a, accuracy: epsilon)
        XCTAssertEqual(pQ.b, PQ.b, accuracy: epsilon)
        XCTAssertEqual(pQ.c, PQ.c, accuracy: epsilon)
        XCTAssertEqual(pQ.d, PQ.d, accuracy: epsilon)
        XCTAssertEqual(pQ.tx, PQ.tx, accuracy: epsilon)
        XCTAssertEqual(pQ.ty, PQ.ty, accuracy: epsilon)
    }
    
    func testPointAddition() throws {
        // translating CGPoint vectors
        var p = point; let q = point
        let P = CGAffineTransform(shift: p), Q = CGAffineTransform(shift: q)
        let PQ = (P*Q).shift, QP = (Q*P).shift
        
        XCTAssertEqual((p+q).x, PQ.x, accuracy: epsilon)
        XCTAssertEqual((p+q).x, QP.x, accuracy: epsilon)
        XCTAssertEqual((p+q).y, PQ.y, accuracy: epsilon)
        XCTAssertEqual((p+q).y, QP.y, accuracy: epsilon)
        
        p += q // test compound assignment
        XCTAssertEqual(p.x, PQ.x, accuracy: epsilon)
        XCTAssertEqual(p.x, QP.x, accuracy: epsilon)
        XCTAssertEqual(p.y, PQ.y, accuracy: epsilon)
        XCTAssertEqual(p.y, QP.y, accuracy: epsilon)
    }
    
    func testPointSizeAddition() throws {
        // translating CGPoint vectors
        var p = point; let q = size
        let P = CGAffineTransform(shift: p), Q = CGAffineTransform(shift: q)
        let PQ = (P*Q).shift, QP = (Q*P).shift
        
        XCTAssertEqual((p+q).x, PQ.x, accuracy: epsilon)
        XCTAssertEqual((p+q).x, QP.x, accuracy: epsilon)
        XCTAssertEqual((p+q).y, PQ.y, accuracy: epsilon)
        XCTAssertEqual((p+q).y, QP.y, accuracy: epsilon)
        
        p += q // test compound assignment
        XCTAssertEqual(p.x, PQ.x, accuracy: epsilon)
        XCTAssertEqual(p.x, QP.x, accuracy: epsilon)
        XCTAssertEqual(p.y, PQ.y, accuracy: epsilon)
        XCTAssertEqual(p.y, QP.y, accuracy: epsilon)
    }
    
    func testSizeAddition() throws {
        // translating CGPoint vectors
        var p = size; let q = size
        let P = CGAffineTransform(shift: p), Q = CGAffineTransform(shift: q)
        let PQ = (P*Q).size, QP = (Q*P).size
        
        XCTAssertEqual((p+q).width, PQ.width, accuracy: epsilon)
        XCTAssertEqual((p+q).width, QP.width, accuracy: epsilon)
        XCTAssertEqual((p+q).height, PQ.height, accuracy: epsilon)
        XCTAssertEqual((p+q).height, QP.height, accuracy: epsilon)
        
        p += q // test compound assignment
        XCTAssertEqual(p.width, PQ.width, accuracy: epsilon)
        XCTAssertEqual(p.width, QP.width, accuracy: epsilon)
        XCTAssertEqual(p.height, PQ.height, accuracy: epsilon)
        XCTAssertEqual(p.height, QP.height, accuracy: epsilon)
    }
    
    func testRotation() throws {
        let angle = random
        let A = CGAffineTransform(rotationAngle:  angle)
        let B = CGAffineTransform(rotationAngle: -angle)
        let Q = A*B
        
        XCTAssertEqual(Q.a, 1.0, accuracy: epsilon)
        XCTAssertEqual(Q.d, 1.0, accuracy: epsilon)
        XCTAssertEqual(Q.b, 0.0, accuracy: epsilon)
        XCTAssertEqual(Q.c, 0.0, accuracy: epsilon)
        XCTAssertEqual(Q.tx,0.0, accuracy: epsilon)
        XCTAssertEqual(Q.ty,0.0, accuracy: epsilon)
    }
    
    func testPrincipalDecomposition() throws {
        let Q = R*S*R*T
        
        let A = CGAffineTransform(rotationAngle: Q.alpha)
        let B = CGAffineTransform(rotationAngle: Q.beta)
        let D = CGAffineTransform(scaleX: Q.scale.x, y: Q.scale.y)
        
        let P = A*D*B + Q.shift
        
        XCTAssertEqual(P.a, Q.a, accuracy: epsilon)
        XCTAssertEqual(P.b, Q.b, accuracy: epsilon)
        XCTAssertEqual(P.c, Q.c, accuracy: epsilon)
        XCTAssertEqual(P.d, Q.d, accuracy: epsilon)
        XCTAssertEqual(P.tx, Q.tx, accuracy: epsilon)
        XCTAssertEqual(P.ty, Q.ty, accuracy: epsilon)
    }
}
