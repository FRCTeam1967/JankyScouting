//
//  EditResultView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/5/22.
//

import CoreData
import SwiftUI

extension Binding {
    init(_ source: Binding<Value?>, _ defaultValue: Value) {
        // Ensure a non-nil value in `source`.
        if source.wrappedValue == nil {
            source.wrappedValue = defaultValue
        }
        // Unsafe unwrap because *we* know it's non-nil now.
        self.init(source)!
    }
}

struct EditResultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    @ObservedObject var result: TeamResult
    
    var body: some View {
        VStack {
            Form {
                Section {
                    Group {
                        Text("Team: \(result.team!.displayName)")
                        Text("Team Number: \(result.team!.teamNumber)")
                    }
                } header: {
                    Text("Team")
                }
                Section {
                    DatePicker("Match date", selection: Binding($result.matchDate, Date.now), displayedComponents: .date)
                    VStack {
                        Text("Alliance Color")
                        Picker("Alliance", selection: Binding($result.alliance, "red")) {
                            Text("Red").tag("red")
                            Text("Blue").tag("blue")
                        }
                        .pickerStyle(.segmented)
                    }
                    Toggle("Defensive capability", isOn: $result.canDefend)
                    Stepper("\(result.lowGoalPoints) low points", value: $result.lowGoalPoints, in: 0...100)
                    Stepper("\(result.highGoalPoints) high points", value: $result.highGoalPoints, in: 0...100)
                    VStack {
                        Text("Highest hang level")
                        Picker("Hang Level", selection:$result.hangLevel) {
                            ForEach(0..<5) {
                                Text("\($0)").tag(Int16($0))
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
                    cancel()
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                .padding()
            }
        }
        .navigationTitle("Edit Report")
    }
    
    func save() {
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func cancel() {
        viewContext.rollback()
    }

}

struct EditView_Previews: PreviewProvider {
    static let moc = PersistenceController.preview.container.viewContext

    static var previews: some View {
        let team = Team(context: moc)
        team.teamName = "The Janksters"
        team.teamNumber = 1967

        let result = TeamResult(context: moc)
        result.matchDate = Date.now
        result.lowGoalPoints = 42
        result.highGoalPoints = 84
        result.canDefend = true
        result.hangLevel = 3
        result.alliance = "blue"
        result.team = team

        return NavigationView {
            EditResultView(result: result)
        }
    }
}
