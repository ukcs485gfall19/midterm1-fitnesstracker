
import UIKit
import HealthKit

class WorkoutsTableViewController: UITableViewController {
  
  private enum WorkoutsSegues: String {
    case showCreateWorkout
    case finishedCreatingWorkout
  }
  
  private var workouts: [HKWorkout]?
  
  private let prancerciseWorkoutCellID = "PrancerciseWorkoutCell"
  
  lazy var dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = false
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadWorkouts()
  }
  
  func reloadWorkouts() {
    WorkoutDataStore.loadWorkouts { (workouts, error) in
      self.workouts = workouts
      self.tableView.reloadData()
    }

  }
  
}
// MARK: - UITableViewDataSource
extension WorkoutsTableViewController {
  override func tableView(_ tableView: UITableView,
                          numberOfRowsInSection section: Int) -> Int {
    return workouts?.count ?? 0
  }
    override func tableView(_ tableView: UITableView,
                    cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let workouts = workouts else {
        fatalError("""
          CellForRowAtIndexPath should \
          not get called if there are no workouts
          """)
      }
        
      //1. Get a cell to display the workout in
      let cell = tableView.dequeueReusableCell(withIdentifier:
        prancerciseWorkoutCellID, for: indexPath)
        
      //2. Get the workout corresponding to this row
      let workout = workouts[indexPath.row]
        
      //3. Show the workout's start date in the label
      cell.textLabel?.text = dateFormatter.string(from: workout.startDate)
        
      return cell
    }

}

