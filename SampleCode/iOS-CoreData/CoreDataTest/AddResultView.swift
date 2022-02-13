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

    @State private var teamName = "1967"
    @State private var alliance = "red"
    @State private var canDefend = true
    @State private var matchDate = Date.now
    @State private var hangLevel = 1
    @State private var lowGoalPoints = 2
    @State private var highGoalPoints = 3
    
    private var logger = Logger()
    
    var body: some View {
        VStack {
            Form {
                Section {
                    TextField("Team Name", text: $teamName)
                } header: {
                    Text("Team")
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

