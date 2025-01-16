//
//  Dashboard.swift
//  LoginApp
//
//  Created by pavan naik on 15/01/25.
//

import SwiftUI

struct Dashboard : View {
    var body: some View {
        ZStack{
            LinearGradient(
                gradient: Gradient(colors: [Color.indigo.opacity(0.3), Color.indigo.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)
            Text("Dashboard")
        }
    }
}

#Preview {
    Dashboard()
}
