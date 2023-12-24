//
//  TrajectoryView.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-24.
//

import SwiftUI

struct TrajectoryView: View {
    @State private var rapidity = acosh(1.5)
    @FocusState private var focus: Bool
    
    // relativistic beta factor
    private var beta: Binding<Double> {
        Binding { tanh(rapidity) } set: { rapidity = atanh($0) }
    }
    
    // relativistic gamma factor
    private var gamma: Binding<Double> {
        Binding { cosh(rapidity) } set: { rapidity = acosh($0) }
    }
    
    var body: some View {
        HStack {
            Slider(value: $rapidity, in: 0.0...acosh(10.0)) { Text("ψ:") } onEditingChanged: { editing in focus = false }.frame(width: 160)
            Text("β:").padding(.trailing, -5).padding(.leading, 5)
            TextField("Latitude", value: beta, formatter: TwoDigitBeta)
                .frame(width: 45).multilineTextAlignment(.trailing).focused($focus)
            Text("ɣ:").padding(.trailing, -5).padding(.leading, 5)
            TextField("Latitude", value: gamma, formatter: TwoDigitGamma)
                .frame(width: 45).multilineTextAlignment(.trailing).focused($focus)
        }
        .padding(.top, 11)
        .padding(.bottom, 10)
    }
}

// number formatter for beta field
let TwoDigitBeta: NumberFormatter = {
    let format = NumberFormatter()
    
    format.minimum = 0.0
    format.maximum = 0.99
    format.minimumFractionDigits = 2
    format.maximumFractionDigits = 2
    format.isLenient = true
    
    return format
}()

// number formatter for gamma field
let TwoDigitGamma: NumberFormatter = {
    let format = NumberFormatter()
    
    format.minimum = 1.0
    format.minimumFractionDigits = 2
    format.maximumFractionDigits = 2
    format.isLenient = true
    
    return format
}()

#Preview {
    TrajectoryView()
}
