//
//  AddResultView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/4/22.
//

import CoreData
import os.log
import SwiftUI

extension Team {
    static func existingTeam(withNumber teamNumber: Int16, context: NSManagedObjectContext) -> Team? {
        // Find the team given by the team number
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        fetchRequest.predicate = NSPredicate(format: "teamNumber = %d", teamNumber)
        let results = try? context.fetch(fetchRequest)
        
        if let results = results {
            // Return what should be the only matching team
            return results[0]
        }
        
        return nil
    }
}

struct AddResultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @FetchRequest(sortDescriptors: [SortDescriptor(\.teamNumber)], predicate: nil, animation: .default)
    private var allTeams: FetchedResults<Team>

    @State private var teamName = "Janksters"
    @State private var teamNumber : Int16 = 1967
    @State private var alliance = "red"
    @State private var canDefend = true
    @State private var matchDate = Date.now
    @State private var hangLevel = 1
    @State private var lowGoalPoints = 2
    @State private var highGoalPoints = 3
    @State private var team : Team?
    
    private var logger = Logger()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Picker("Team", selection: $team) {
                        Text("New Team").tag(nil as Team?)
                        ForEach(allTeams, id: \.self) { team in
                            Text("\(team.teamNumber) (\(team.displayName))").tag(team as Team?)
                        }
                    }
                    if (team == nil) {
                        Group {
                            TextField("Team Name", text: $teamName)
                            TextField("Team Number", value: $teamNumber, format: .number)
                        }
                    }
                } header: {
                    Text("Choose an existing team, or create a new one")
                }
                Section {
                    DatePicker("Match date", selection: $matchDate, displayedComponents: .date)
                    VStack {
                        Text("Alliance Color")
                        Picker("Alliance", selection: $alliance) {
                            Text("Red").tag("red")
                            Text("Blue").tag("blue")
                        }
                        .pickerStyle(.segmented)
                    }
                    Toggle("Defensive capability", isOn: $canDefend)
                    Stepper("\(lowGoalPoints) low points", value: $lowGoalPoints, in: 0...100)
                    Stepper("\(highGoalPoints) high points", value: $highGoalPoints, in: 0...100)
                    VStack {
                        Text("Highest hang level")
                        Picker("Hang Level", selection:$hangLevel) {
                            ForEach(0..<5) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                } header: {
                    Text("Match Information")
                }
            }
            HStack {
                Button("Save") {
                    save()
                    dismiss()
                }
                .padding()
                Spacer()
                Button(role: .cancel) {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .padding()
            }
        }
        .navigationTitle("New Report")
    }
    
    func findExistingTeam() -> Team {
        // Find the team given by the team number, or create a new one
        let fetchRequest = NSFetchRequest<Team>(entityName: "Team")
        fetchRequest.predicate = NSPredicate(format: "teamNumber = %d", teamNumber)
        let results = try? viewContext.fetch(fetchRequest)
        
        if let results = results {
            // Return what should be the only matching team
            logger.log("Found existing team with teamNumber = \(teamNumber)!")
            return results[0]
        } else {
            logger.log("Creating new Team object")
            let newTeam = Team()
            newTeam.teamNumber = teamNumber
            if (teamName.count > 0) {
                newTeam.teamName = teamName
            }
            
            return newTeam
        }
    }

    func save() {
        do {
            var teamToUse: Team! = nil
            
            // Enforce uniqueness on teamNumber
            if team == nil {
                // We don't want to allow duplicates, so we need to make sure there's no existing team
                team = Team.existingTeam(withNumber: teamNumber, context: viewContext)
                
                if team != nil {
                    logger.log("Found an existing team with that number even though the user didn't choose it!")
                    teamToUse = team
                    if (teamToUse.teamName != teamName) {
                        logger.log("Updating existing team name: \(teamToUse.teamName ?? "<empty>") => \(teamName)")
                        teamToUse.teamName = teamName
                    }
                } else {
                    logger.log("No existing team with that number; creating one!")
                    teamToUse = Team()
                    teamToUse.teamName = teamName.count > 0 ? teamName : nil
                    teamToUse.teamNumber = teamNumber
                }
            } else {
                teamToUse = team
            }
            
            let newResult = TeamResult(context: viewContext)
            newResult.team = teamToUse
    
            newResult.matchDate = matchDate
            newResult.alliance = alliance
            newResult.canDefend = canDefend
            newResult.hangLevel = Int16(hangLevel)
            newResult.highGoalPoints = Int16(highGoalPoints)
            newResult.lowGoalPoints = Int16(lowGoalPoints)
            
            logger.log("Hang level is \(hangLevel)")
            
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    

}

struct AddResultView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            AddResultView()
        }
    }
}

