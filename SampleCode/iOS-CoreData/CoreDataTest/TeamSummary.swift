//
//  TeamSummary.swift
//  CoreDataTest
//
//  Created by Michael Santos on 2/7/22.
//

import CoreData
import SwiftUI

// Compute a summary given a set of TeamResults

struct TeamSummary {
    var avgLowGoalPoints = 0.0
    var avgHighGoalPoints = 0.0
    var avgHangLevel = 0.0

    var maxLowGoalPoints = 0
    var maxHighGoalPoints = 0
    var maxHangLevel = 0
    
    private var team: Team
    
    init(fromTeam teamToView: Team) {
        team = teamToView
        let results = team.results as? Set<TeamResult> // Convert CD's NSSet to Swift
        guard let results = results else {
            return
        }
        
        var lowGoalSum = 0
        var highGoalSum = 0
        var hangLevelSum = 0
        for record in results {
            lowGoalSum += Int(record.lowGoalPoints)
            highGoalSum += Int(record.highGoalPoints)
            hangLevelSum += Int(record.hangLevel)
            
            maxLowGoalPoints = max(maxLowGoalPoints, Int(record.lowGoalPoints))
            maxHighGoalPoints = max(maxHighGoalPoints, Int(record.highGoalPoints))
            maxHangLevel = max(maxHangLevel, Int(record.hangLevel))
        }
        
        let recordCount = Double(results.count)
        avgLowGoalPoints = Double(lowGoalSum) / recordCount
        avgHighGoalPoints = Double(highGoalSum) / recordCount
        avgHangLevel = Double(hangLevelSum) / recordCount
    }
    
    
    // A computed property just because
    var numMatches : Int {
        if let results = team.results {
            return results.count
        }
        return 0
    }
    
    var teamName : String {
        team.teamName ?? "Team \(team.teamNumber)"
    }
}
