//
//  DelayController.swift
//  hauler
//
//  Created by Homing Lau on 2023-06-21.
//

import Foundation

class DelayManager {
    var workItem: DispatchWorkItem?
    
    func start(delay: TimeInterval, closure: @escaping () -> Void) {
        cancel()
        
        let newWorkItem = DispatchWorkItem { [weak self] in
            closure()
            self?.workItem = nil
        }
        workItem = newWorkItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: newWorkItem)
    }
    
    func extend(delay: TimeInterval) {
        if let existingWorkItem = workItem {
            existingWorkItem.cancel()
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: existingWorkItem)
        }
    }
    
    func cancel() {
        workItem?.cancel()
        workItem = nil
    }
}
