//
//  MainMenuView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/6/22.
//

import CoreData
import SwiftUI

struct MainMenuView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingConfirmationAlert = false
    @State private var confirmationTitle = ""
    @State private var confirmationBody = ""
    @State private var confirmationAction : () -> Void = {}

    @State private var cachedRecordCount = 0
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section("FRC Match Results") {
                        NavigationLink("Add new entry") {
                            AddResultView()
                        }
                        NavigationLink("View entries") {
                            ResultsListView()
                        }
                    }
                    Section("View stats by team") {
                        NavigationLink("Analysis") {
                            TeamListView()
                        }
                    }
                    Section("Data Export") {
                        NavigationLink("Export") {
                            ExportView()
                        }
                    }
                    Section("Debugging") {
                        Button("Reset database", role:.destructive) {
                            confirmationAction = deleteAllRecords
                            confirmationTitle = "Reset Database"
                            confirmationBody = "Are you sure you want to reset the database? All records will be deleted."
                            showingConfirmationAlert = true
                        }
                        Button("Generate fake data") {
                            confirmationAction = generateFakeRecords
                            confirmationTitle = "Add Fake Data"
                            confirmationBody = "Are you sure you want to add a bunch of fake records to the database?"
                            showingConfirmationAlert = true
                        }
                    }
                }
                
                Spacer()
                Text("Scouting reports: \(cachedRecordCount)")
                    .padding()
            }
            .navigationTitle("Scouting")
            .listStyle(.insetGrouped)
            .background(Color(UIColor.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
            .alert(confirmationTitle, isPresented: $showingConfirmationAlert) {
                Button("OK", role:.destructive) {
                    confirmationAction()
                }
                Button ("Cancel", role:.cancel) { }
            } message: {
                Text(confirmationBody)
            }
            .onAppear {
                // This is not sufficient. It doesn't update if you add records through the add records view.
                cachedRecordCount = recordCount
            }
            .onReceive(NotificationCenter.default.publisher(for: .NSManagedObjectContextDidSave)) { _ in
                cachedRecordCount = recordCount
            }
        }
    }
    
    func deleteAllRecords() {
        do {
            // There's probably a better way to do this
            let fetchRequest = NSFetchRequest<TeamResult>(entityName: "TeamResult")
            fetchRequest.returnsObjectsAsFaults = true // Don't fault in the data
            let results = try viewContext.fetch(fetchRequest)
            for item in results {
                viewContext.delete(item)
            }
            
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func generateFakeRecords() {
        for _ in 1...50 {
            let teamName = "\(Int.random(in: 1...3000))"
            // We need some duplicates otherwise the averages view doesn't do anything useful
            for _ in 1...3 {
                let newResult = TeamResult(context: viewContext)
                newResult.teamName = teamName
                newResult.alliance = Bool.random() ? "red" : "blue"
                newResult.hangLevel = Int16.random(in: 0...4)
                newResult.canDefend = Bool.random()
                newResult.lowGoalPoints = Int16.random(in: 0...100)
                newResult.highGoalPoints = Int16.random(in: 0...100)
                newResult.matchDate = Date.now.addingTimeInterval(Double.random(in: -365*24*60*60...0)) // sometime in the past year
            }
        }
        
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        
    }
    
    var recordCount : Int {
        var recordCount = 0
        if let count = try? viewContext.count(for: NSFetchRequest<NSFetchRequestResult>(entityName: "TeamResult")) {
            recordCount = count
        }

        return recordCount
    }
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        MainMenuView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
