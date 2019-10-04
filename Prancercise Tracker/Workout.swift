

import Foundation

struct OneHourWalkerInterval {
  
  var start: Date
  var end: Date
  
  var duration: TimeInterval {
    return end.timeIntervalSince(start)
  }
  

}
struct OneHourWalker {
  var start: Date
  var end: Date
  var intervals: [OneHourWalkerInterval]
  
  init(with intervals: [OneHourWalkerInterval]) {
    self.start = intervals.first!.start
    self.end = intervals.last!.end
    self.intervals = intervals
  }

    var duration: TimeInterval {
      return intervals.reduce(0) { (result, interval) in
        result + interval.duration
      }
    }

}

