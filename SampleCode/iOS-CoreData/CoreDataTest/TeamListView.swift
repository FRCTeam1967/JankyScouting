//
//  TeamListView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/6/22.
//

import CoreData
import os.log
import SwiftUI


extension TeamResult {
    // The @FetchRequest property wrapper in the body will call this function
    static func uniqueTeamNamesFetchRequest() -> NSFetchRequest<NSDictionary> {
        let request: NSFetchRequest<NSDictionary> = TeamResult.fetchRequest() as! NSFetchRequest<NSDictionary>
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TeamResult.teamName, ascending: true)]
       request.returnsDistinctResults = true
        request.resultType = .dictionaryResultType
        request.propertiesToFetch = ["teamName"]

        return request
    }
}


struct TeamListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var uniqueTeamNames : [String] = []
    
    private var logger = Logger()
    
    var body: some View {
        VStack {
            List {
                ForEach($uniqueTeamNames, id:\.self) { name in
                    NavigationLink {
                        TeamMetricsView(teamName: name.wrappedValue)
                    } label: {
                        Text("\(name.wrappedValue)")
                    }
                }
            }
        }
        .navigationTitle("All Teams")
        .onAppear() {
            // Ideally we'd not do this fetch right as we're trying to show the view, as it can slow
            // down presentation of the view.
            let fetchRequest = TeamResult.uniqueTeamNamesFetchRequest()
            do {
                let teamNames = try viewContext.fetch(fetchRequest)
                logger.log("Got \(teamNames.count) results")
                
                uniqueTeamNames = []
                for dict in teamNames {
                    let teamName = dict["teamName"] as! String
                    uniqueTeamNames.append(teamName)
                    logger.log("Adding team: \(teamName)")
                }
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct TeamListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TeamListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
