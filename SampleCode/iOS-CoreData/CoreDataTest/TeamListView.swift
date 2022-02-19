//
//  TeamListView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/6/22.
//

import CoreData
import os.log
import SwiftUI

extension Team {
    // Helper extension to give us a string to display -- either the actual team name, or a synthesized one
    // from the team numbrer.
    var displayName : String {
        return teamName ?? "Team #\(teamNumber)"
    }
}

struct TeamListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // With team as a separate entity, we get naturally uniquing.
    @FetchRequest(sortDescriptors: [SortDescriptor(\.teamNumber)], predicate: nil, animation: .default)
    private var results: FetchedResults<Team>
    
    private var logger = Logger()
    
    var body: some View {
        VStack {
            List {
                ForEach(results, id:\.self) { team in
                    NavigationLink {
                        TeamMetricsView(team: team)
                    } label: {
                        Text("\(team.displayName)")
                    }
                }
            }
        }
        .navigationTitle("All Teams")
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
