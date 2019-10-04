

import HealthKit

class WorkoutDataStore {
  
    @available(iOS 12.0, *)
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

  
    
        
    
   
       
    
    
          
      //2. Finish collection workout data and set the workout end date
      builder.endCollection(withEnd: OneHourWalker.end) { (success, error) in
        guard success else {
          completion(false, error)
          return
        }
            
        //3. Create the workout with the samples added
        builder.finishWorkout { (_, error) in
          let success = error == nil
          completion(success, error)
        }
      }
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
