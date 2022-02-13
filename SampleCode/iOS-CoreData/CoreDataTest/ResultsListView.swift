//
//  ResultsListView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/1/22.
//

import SwiftUI
import CoreData

struct ResultsListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingAddScreen = false

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TeamResult.matchDate, ascending: true)],
        animation: .default)
    private var items: FetchedResults<TeamResult>

    var body: some View {
        List {
            ForEach(items) { item in
                NavigationLink {
                    EditResultView(result: item)
                } label: {
                    HStack {
                        Text("Team \(item.teamName!)")
                        Spacer()
                        Text("\(item.matchDate!.formatted())")
                    }
                }
            }
            .onDelete(perform: deleteItems)
        }
        .navigationTitle("View/Edit Reports")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddScreen.toggle()
                } label: {
                    Label("Add Report", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddScreen) {
            NavigationView {
                AddResultView()
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ResultsListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ResultsListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
