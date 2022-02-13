//
//  ExportView.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/9/22.
//

import CoreData
import os.log
import SwiftUI

extension TeamResult {
    static func appendCSVHeader(toFile file: FileHandle) {
        let headerData = "Team Name, Match Date, Can Defend, Low Goal Points, High Goal Points, Hang Level, Alliance\n".data(using: .utf8)
        if let headerData = headerData {
            try! file.write(contentsOf: headerData)
        }
    }

    func appendCSV(toFile file: FileHandle) {
        let csvRow = "\(teamName!), \(matchDate!), \(canDefend), \(lowGoalPoints), \(highGoalPoints), \(hangLevel), \(alliance!)\n"
        let csvData = csvRow.data(using: .utf8)
        if let csvData = csvData {
            try! file.write(contentsOf: csvData)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    typealias Callback = (_ activityType: UIActivity.ActivityType?, _ completed: Bool, _ returnedItems: [Any]?, _ error: Error?) -> Void
    
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil
    let callback: Callback? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        controller.completionWithItemsHandler = callback
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // nothing to do here
    }
}


struct ExportView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showingShareSheet = false
    
    @State private var showingAlert = false
    @State private var alertTitle = ""
    @State private var alertBody = ""
    
    @State private var exportURL: URL? = nil
    
    private var logger = Logger()

    var body: some View {
        List {
            Section("CSV Export") {
                Button(exportURL != nil ? "Regenerate" : "Generate") {
                    exportURL = generateExportCSV()
                    if exportURL == nil {
                        alertTitle = "Export failed!"
                        alertBody = "Failed to generate the comma-separated value file (for some reason)"
                        showingAlert = true
                    } else {
                        alertTitle = "Export"
                        alertBody = "Data successfully exported!"
                        showingAlert = true
                    }
                }
                Button("Share") {
                    showingShareSheet = true
                }
                .disabled(exportURL == nil)
            }
        }
        .navigationTitle("Export")
        .listStyle(.insetGrouped)
        .background(Color(UIColor.systemGroupedBackground))
        .edgesIgnoringSafeArea(.bottom)
        .alert(alertTitle, isPresented: $showingAlert) {
        } message: {
            Text(alertBody)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [exportURL as Any])
        }
    }
    
    // This would be a good place to use the async await pattern, but I don't know how to use that yet...
    func generateExportCSV() -> URL? {
        // We should always have a document directory!
        let fileManager = FileManager.default
        let documentURL = try! fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let fileURL = documentURL.appendingPathComponent("export.csv")
        let fetchRequest = NSFetchRequest<TeamResult>(entityName: "TeamResult")
        do {
            // Create an empty file, or truncate the existing one
            try Data().write(to: fileURL)

            let fileHandle = try FileHandle(forWritingTo: fileURL)
            try fileHandle.truncate(atOffset: 0)
            let allResults = try viewContext.fetch(fetchRequest)
            TeamResult.appendCSVHeader(toFile: fileHandle)
            for result in allResults {
                result.appendCSV(toFile: fileHandle)
            }
            try fileHandle.close()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            logger.log("Unresolved error \(nsError), \(nsError.userInfo)")
            
            return nil
        }
        
        return fileURL
    }
}

struct ExportView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ExportView()
        }
    }
}
