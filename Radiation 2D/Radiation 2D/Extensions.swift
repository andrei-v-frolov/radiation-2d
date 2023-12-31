//
//  Extensions.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import simd
import Foundation

// MARK: SIMD extensions

extension SIMD4 {
    var q: SIMD2<Scalar> { SIMD2<Scalar>(self.x, self.y) }
    var p: SIMD2<Scalar> { SIMD2<Scalar>(self.z, self.w) }
    var xy: SIMD2<Scalar> { SIMD2<Scalar>(self.x, self.y) }
    var xyz: SIMD3<Scalar> { SIMD3<Scalar>(self.x, self.y, self.z) }
}


// MARK: Core Graphics extensions

// type bridging
extension CGPoint {
    init(_ v: CGVector) { self.init(x: v.dx, y: v.dy) }
    init(_ v: SIMD2<Double>) { self.init(x: v.x, y: v.y) }
    init(_ size: CGSize) { self.init(x: size.width, y: size.height) }
    
    var coords: SIMD2<Double> { SIMD2<Double>(x, y) }
}

extension CGSize {
    init(_ v: CGVector) { self.init(width: v.dx, height: v.dy) }
    init(_ v: SIMD2<Double>) { self.init(width: v.x, height: v.y) }
    init(_ point: CGPoint) { self.init(width: point.x, height: point.y) }
    
    var coords: SIMD2<Double> { SIMD2<Double>(width, height) }
}

extension CGVector {
    init(_ v: SIMD2<Double>) { self.init(dx: v.x, dy: v.y) }
    init(_ point: CGPoint) { self.init(dx: point.x, dy: point.y) }
    init(_ size: CGSize) { self.init(dx: size.width, dy: size.height) }
    
    var coords: SIMD2<Double> { SIMD2<Double>(dx, dy) }
}


extension CGRect {
    init(_ v: SIMD4<Double>) { self.init(x: v.x, y: v.y, width: v.z, height: v.w) }
    var shape: SIMD4<Double> { SIMD4<Double>(minX, minY, width, height) }
}

// affine transforms
extension CGAffineTransform {
    // convenience initializers
    init(scale: CGFloat) { self.init(scaleX: scale, y: scale) }
    init(shift: CGPoint) { self.init(translationX: shift.x, y: shift.y) }
    init(shift: CGSize) { self.init(translationX: shift.width, y: shift.height) }
    
    // principal decomposition Q = rotation(alpha)*diag(p,q)*rotation(beta) + shift
    var SVD: (p: CGFloat, q: CGFloat, alpha: CGFloat, beta: CGFloat) {
        let phi = atan2(self.b-self.c, self.d+self.a)   // alpha + beta
        let psi = atan2(self.b+self.c, self.d-self.a)   // alpha - beta
        let u = (self.a+self.d)/cos(phi)                // p + q
        let v = (self.a-self.d)/cos(psi)                // p - q
        
        return (p: (u+v)/2.0, q: (u-v)/2.0, alpha: (phi+psi)/2.0, beta: (phi-psi)/2.0)
    }
    
    // individual parameters
    var alpha: CGFloat { return self.SVD.alpha }
    var beta:  CGFloat { return self.SVD.beta  }
    var scale: CGPoint { let svd = self.SVD; return CGPoint(x: svd.p, y: svd.q) }
    var shift: CGPoint { return CGPoint(x: self.tx, y: self.ty) }
    var size: CGSize { return CGSize(width: self.tx, height: self.ty) }
}

// affine transform composition, applied from left to right, i.e. (A*B)(I) = B(A(I))
func *(A: CGAffineTransform, B: CGAffineTransform) -> CGAffineTransform { return A.concatenating(B) }

// single float represents uniform scaling, same associativity rules
func *(A: CGAffineTransform, s: CGFloat) -> CGAffineTransform { return A.concatenating(CGAffineTransform(scale: s)) }
func *(s: CGFloat, A: CGAffineTransform) -> CGAffineTransform { return A.scaledBy(x: s, y: s) }

// scaling of vectors, defined from the right to keep consistent order
func *(p: CGPoint, s: CGFloat) -> CGPoint { return CGPoint(x: p.x*s, y: p.y*s) }
func /(p: CGPoint, s: CGFloat) -> CGPoint { return CGPoint(x: p.x/s, y: p.y/s) }
func *(q: CGSize,  s: CGFloat) -> CGSize  { return CGSize(width: q.width*s, height: q.height*s) }
func /(q: CGSize,  s: CGFloat) -> CGSize  { return CGSize(width: q.width/s, height: q.height/s) }

// single vector represents translation, same associativity rules
func +(A: CGAffineTransform, p: CGPoint) -> CGAffineTransform { return A.concatenating(CGAffineTransform(shift:  p)) }
func -(A: CGAffineTransform, p: CGPoint) -> CGAffineTransform { return A.concatenating(CGAffineTransform(shift: -p)) }
func +(A: CGAffineTransform, q: CGSize) -> CGAffineTransform { return A.concatenating(CGAffineTransform(shift:  q)) }
func -(A: CGAffineTransform, q: CGSize) -> CGAffineTransform { return A.concatenating(CGAffineTransform(shift: -q)) }

func +(p: CGPoint, A: CGAffineTransform) -> CGAffineTransform { return A.translatedBy(x: p.x, y: p.y) }
func +(p: CGSize, A: CGAffineTransform) -> CGAffineTransform { return A.translatedBy(x: p.width, y: p.height) }

// adddition of vectors, commutative
func +(p: CGPoint, q: CGPoint) -> CGPoint { return CGPoint(x: p.x+q.x, y: p.y+q.y) }
func -(p: CGPoint, q: CGPoint) -> CGPoint { return CGPoint(x: p.x-q.x, y: p.y-q.y) }
func +(p: CGPoint, q: CGSize) -> CGPoint { return CGPoint(x: p.x+q.width, y: p.y+q.height) }
func -(p: CGPoint, q: CGSize) -> CGPoint { return CGPoint(x: p.x-q.width, y: p.y-q.height) }
func +(p: CGSize, q: CGSize) -> CGSize { return CGSize(width: p.width+q.width, height: p.height+q.height) }
func -(p: CGSize, q: CGSize) -> CGSize { return CGSize(width: p.width-q.width, height: p.height-q.height) }

// compound assignment operators
func +=(p: inout CGPoint, q: CGPoint) { p.x += q.x; p.y += q.y }
func -=(p: inout CGPoint, q: CGPoint) { p.x -= q.x; p.y -= q.y }
func +=(p: inout CGPoint, q: CGSize) { p.x += q.width; p.y += q.height }
func -=(p: inout CGPoint, q: CGSize) { p.x -= q.width; p.y -= q.height }
func +=(p: inout CGSize, q: CGSize) { p.width += q.width; p.height += q.height }
func -=(p: inout CGSize, q: CGSize) { p.width -= q.width; p.height -= q.height }

// unary operators
prefix func +(p: CGPoint) -> CGPoint { return p }
prefix func +(q: CGSize) -> CGSize  { return q }
prefix func -(p: CGPoint) -> CGPoint { return CGPoint(x: -p.x, y: -p.y) }
prefix func -(q: CGSize) -> CGSize  { return CGSize(width: -q.width, height: -q.height) }
