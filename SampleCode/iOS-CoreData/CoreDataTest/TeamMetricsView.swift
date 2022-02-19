//
//  TeamMetricsView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/6/22.
//

import CoreData
import os.log
import SwiftUI

struct TeamMetricsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    private var logger = Logger()
    private var team: Team
    
    init(team teamToView: Team) {
        team = teamToView
    }
    
    var body: some View {
        let teamSummary = TeamSummary(fromTeam: team)
        
        return List {
            Section("Hanger Zone") {
                Text("Average bar: \(teamSummary.avgHangLevel.formatted())")
                Text("Highest bar achieved: \(teamSummary.maxHangLevel)")
            }
            Section("Low Goal") {
                Text("Average score: \(teamSummary.avgLowGoalPoints.formatted()) points")
                Text("Best score: \(teamSummary.maxLowGoalPoints) points")
            }
            Section("High Goal") {
                Text("Average score: \(teamSummary.avgHighGoalPoints.formatted()) points")
                Text("Best score: \(teamSummary.maxHighGoalPoints) points")
            }
        }
        .navigationTitle("\(team.displayName) Analysis")
    }
}
    
//struct SummaryDetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            TeamMetricsView(teamName: "1").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//        }
//    }
//}
