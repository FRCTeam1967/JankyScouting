//
//  TeamMetricsView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/6/22.
//

import CoreData
import os.log
import SwiftUI

// Helper extension to generate our fetch request.
extension TeamResult {
    static func teamResultsFetchRequest(teamName: String) -> NSFetchRequest<TeamResult> {
        let request: NSFetchRequest<TeamResult> = TeamResult.fetchRequest()
        request.predicate = NSPredicate(format: "teamName == %@", teamName)

        return request
    }
}

struct TeamMetricsView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // fetch request property wrapper. I believe this automatically updates when the data store changes.
    @FetchRequest(sortDescriptors: [], predicate: NSPredicate(format: "teamName == ''"), animation: .default)
    private var results: FetchedResults<TeamResult>

    private var logger = Logger()
    private var teamName = ""
    
    init(teamName name: String) {
        teamName = name
    }
    
    var body: some View {
        let teamSummary = TeamSummary(fromFetchResults: results)
        
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
        .navigationTitle("Team \(teamName) Analysis")
        .onAppear {
            // Update the fetch request with the real predicate
            results.nsPredicate = NSPredicate(format: "teamName == %@", teamName)
        }
    }
}
    
struct SummaryDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamMetricsView(teamName: "1").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
