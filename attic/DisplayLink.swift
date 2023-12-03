//
//  DisplayLink.swift
//  Radiation 2D
//
//  Created by Andrei Frolov on 2023-12-01.
//

import SwiftUI

#if os(iOS)
@MainActor final class DisplayLink: NSObject, ObservableObject {
    private var link: CADisplayLink? = nil
    
    override init() {
        super.init()
        let link = CADisplayLink(target: self, selector: #selector(frame))
        link.add(to: .current, forMode: RunLoop.Mode.default)
    }
    
    deinit { if let link = link { link.invalidate() } }
    
    @objc func frame(link: CADisplayLink) {
        print(link.timestamp)
    }
}
#endif

#if os(macOS)
@MainActor final class DisplayLink: NSObject, ObservableObject {
    private var link: CVDisplayLink? = nil
    
    typealias Callback = (_ time: Double) -> Void
    private let callback: Callback
    
    init(onFrame: @escaping Callback) {
        callback = onFrame; super.init()
        
        CVDisplayLinkCreateWithActiveCGDisplays(&link)
        guard let link = link else { return }
        
        CVDisplayLinkSetOutputHandler(link) { [weak self] link,now,target,_,_ in
            let stamp = target.pointee; print(stamp)
            self?.callback(Double(stamp.videoTime)/Double(stamp.videoTimeScale))
            return 0
        }
        
        CVDisplayLinkStart(link)
    }
    
    deinit { if let link = link { CVDisplayLinkStop(link) } }
}
#endif
