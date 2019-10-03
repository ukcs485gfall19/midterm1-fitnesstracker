

import Foundation

struct PrancerciseWorkout {
  
  var start: Date
  var end: Date
  
  init(start: Date, end: Date) {
    self.start = start
    self.end = end
  }
  
  var duration: TimeInterval {
    return end.timeIntervalSince(start)
  }
  
  var totalEnergyBurned: Double {
    
    let prancerciseCaloriesPerHour: Double = 450
    
    let hours: Double = duration/3600
    
    let totalCalories = prancerciseCaloriesPerHour*hours
    
    return totalCalories
  }
}
