//
//  ViewHelpers.swift
//  SmartSessionRecovery
//
//  Created by Noman belim on 11/02/26.
//

import Foundation
import SwiftUI

struct VisibilityTracker: ViewModifier {
    let index: Int
    @Binding var tracker: Int
    
    func body(content: Content) -> some View {
        content
            .onAppear {
               
                tracker = index
            }
    }
}

extension View {
    func trackVisibility(index: Int, tracker: Binding<Int>) -> some View {
        self.modifier(VisibilityTracker(index: index, tracker: tracker))
    }
}
