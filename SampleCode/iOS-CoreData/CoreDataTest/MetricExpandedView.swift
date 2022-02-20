//
//  MetricExpandedView.swift
//  CoreDataTest
//
//  Created by Anchal Bhardwaj on 2/17/22.
//

import SwiftUI

struct MetricExpandedView: View {

    
    var body: some View {
        
        return List {
            Section("Hanger Zone") {
                Text("Qualification #")
                Text("Qualification #")
                Text("Qualification #")
            }
            Section("Low Goal") {
                Text("Qualification #")
                Text("Qualification #")
                Text("Qualification #")
            }
            Section("High Goal") {
                Text("Qualification #")
                Text("Qualification #")
                Text("Qualification #")
            }
        } .navigationTitle("Expanded Analysis")
    }
}

struct MetricExpandedView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MetricExpandedView()
        }
    }
}
