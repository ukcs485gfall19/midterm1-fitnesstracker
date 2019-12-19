

import HealthKit


class WorkoutDataStore {
  
   
    class func save(OneHourWalker: OneHourWalker,
                  completion: @escaping ((Bool, Error?) -> Swift.Void)) {
    let healthStore = HKHealthStore()
        
    let workoutConfiguration = HKWorkoutConfiguration()
    workoutConfiguration.activityType = .other
    let builder = HKWorkoutBuilder(healthStore: healthStore,
                                       configuration: workoutConfiguration,
                                       device: .local())
    
    builder.beginCollection(withStart: OneHourWalker.start) { (success, error) in
      guard success else {
        completion(false, error)
        return
      }
    }
    
        let samples = self.samples(for: OneHourWalker)
          
          builder.add(samples) { (success, error) in
            guard success else {
              completion(false, error)
              return
            }
            
            builder.endCollection(withEnd: OneHourWalker.end) { (success, error) in
              guard success else {
                completion(false, error)
                return
              }
              
              builder.finishWorkout { (workout, error) in
                let success = error == nil
                completion(success, error)
              }
            }
          }
    }
    
        
        private class func samples(for workout: OneHourWalker) -> [HKSample] {
          //1. Verify that the energy quantity type is still available to HealthKit.
          guard let energyQuantityType = HKSampleType.quantityType(
            forIdentifier: .activeEnergyBurned) else {
                fatalError("*** Energy Burned Type Not Available ***")
          }
        
    let samples: [HKSample] = workout.intervals.map { interval in
        let calorieQuantity = HKQuantity(unit: .kilocalorie(),
                                         doubleValue: interval.totalEnergyBurned)
        
        return HKCumulativeQuantitySeriesSample(type: energyQuantityType,
                                                      quantity: calorieQuantity,
                                                      start: interval.start,
                                                      end: interval.end)
      }
      
      return samples
    }

    
    

    
    class func loadWorkouts(completion:
      @escaping ([HKWorkout]?, Error?) -> Void) {
      //1. Get all workouts with the "Other" activity type.
      let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
      
      //2. Get all workouts that only came from this app.
      let sourcePredicate = HKQuery.predicateForObjects(from: .default())
      
      //3. Combine the predicates into a single predicate.
      let compound = NSCompoundPredicate(andPredicateWithSubpredicates:
        [workoutPredicate, sourcePredicate])
      
      let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,
                                            ascending: true)

        let query = HKSampleQuery(
          sampleType: .workoutType(),
          predicate: compound,
          limit: 0,
          sortDescriptors: [sortDescriptor]) { (query, samples, error) in
            DispatchQueue.main.async {
              guard
                let samples = samples as? [HKWorkout],
                error == nil
                else {
                  completion(nil, error)
                  return
              }
              
              completion(samples, nil)
            }
          }

        HKHealthStore().execute(query)

    }
    

}
