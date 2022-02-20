//
//  AddResultView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/4/22.
//

import CoreData
import os.log
import SwiftUI

struct AddResultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    

    @State private var teamName = ""
    @State private var scoutName = ""
    @State private var alliance = "red"
    @State private var canDefend = false
    @State private var isTallBot = false
    @State private var didLoseComms = false
    @State private var matchDate = Date.now
    @State private var hangLevel = 1
    @State private var lowGoalPoints = 0
    @State private var highGoalPoints = 0
    @State private var shootingPosition = 1
    @State private var positionList = ["Tarmac Edge", "Fender", "Launchpad", "Did not shoot", "Other"]
    
    @State private var defenseRating = 1
    @State private var maneuverabilityRating = 1
    @State private var speedRating = 1
    
    
    private var logger = Logger()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Team Name", text: $teamName)
                    TextField("Scout Name", text: $scoutName)
                } header: {
                    Text("Team")
                }
                
                Section {
                    HStack{
                        Image(systemName: "calendar")
                        DatePicker("Match date", selection: $matchDate, displayedComponents: .date)
                    }
                    VStack {
                        Text("Alliance Color")
                        Picker("Alliance", selection: $alliance) {
                            Text("Red").tag("red")
                            Text("Blue").tag("blue")
                        }
                        .pickerStyle(.segmented)
                             
                    }
                    HStack{
                        Image(systemName: "sportscourt")
                        Toggle("Defensive capability?", isOn: $canDefend).tint(.red)   
                    }
                    
                    HStack{
                        Image(systemName: "wrench")
                        Toggle("Tall Bot?", isOn: $isTallBot) .tint(.red)
                    }
                } header: {
                    Text("Prematch")
                }
                
                
                Section {
                    HStack{
                        Image(systemName: "chevron.down.circle")
                        Stepper("\(lowGoalPoints) low points", value: $lowGoalPoints, in: 0...100)
                    }
                    HStack{
                        Image(systemName: "chevron.up.circle")
                        Stepper("\(highGoalPoints) high points", value: $highGoalPoints, in: 0...100)
                    }
                   
                    VStack{
                        HStack {
                        Text("Shooting Position")
                        Picker("Position", selection:$shootingPosition) {
                            //Text("Edge of Tarmac").tag($0)
                            ForEach(positionList.indices) {
                              Text(self.positionList[$0])
                            }
                        }
                        .pickerStyle(.menu)
                        }
                    }
                        
                    
                    VStack {
                        Text("Highest hang level")
                        Picker("Hang Level", selection:$hangLevel) {
                            ForEach(0..<5) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    HStack {
                    Image(systemName: "exclamationmark.bubble")
                    Toggle("Lost Comms", isOn: $didLoseComms) .tint(.red)
                    }
                
                } header: {
                    Text("Match Information")
                }
                
                Section {
                    
                    VStack {
                        Text("Defense Capabilities")
                        Picker("Defense Capabilities", selection:$defenseRating) {
                            ForEach(0..<10) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack {
                        Text("Maneuverability")
                        Picker("Maneuverability", selection:$maneuverabilityRating) {
                            ForEach(0..<10) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    VStack {
                        Text("Speed Capabilities")
                        Picker("Speed", selection:$speedRating) {
                            ForEach(0..<10) {
                                Text("\($0)").tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    
                } header: {
                    Text("Post Match")
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

    func save() {
        do {
            let editRecord = TeamResult(context: viewContext)
    
            editRecord.matchDate = matchDate
            editRecord.alliance = alliance
            editRecord.canDefend = canDefend
            editRecord.hangLevel = Int16(hangLevel)
            editRecord.highGoalPoints = Int16(highGoalPoints)
            editRecord.lowGoalPoints = Int16(lowGoalPoints)
            editRecord.teamName = teamName
            
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

