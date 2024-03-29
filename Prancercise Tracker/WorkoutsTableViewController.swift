
import UIKit
import HealthKit


class WorkoutsTableViewController: UITableViewController {

  private enum WorkoutsSegues: String {
    case showCreateWorkout
    case finishedCreatingWorkout
  }
  
  private var workouts: [HKWorkout]?
  
  private let OneHourWalkerCellID = "OneHourWalkerCell"
  
  lazy var dateFormatter:DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeStyle = .short
    formatter.dateStyle = .medium
    return formatter
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    self.clearsSelectionOnViewWillAppear = false
    NotificationCenter.default.addObserver(self, selector: #selector(WorkoutsTableViewController.reloadWorkouts), name: Notification.Name(rawValue: "loadWorkouts"), object: nil)
    tableView.dataSource = self
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    reloadWorkouts()
  }
  
    @objc func reloadWorkouts() {
        DispatchQueue.main.async {
            WorkoutDataStore.loadWorkouts { (workouts, error) in
                self.workouts = workouts
                self.tableView.reloadData()
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            }
            
        }

  
  
}
}

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
        let cell = tableView.dequeueReusableCell(withIdentifier: OneHourWalkerCellID, for: indexPath)
        
      //2. Get the workout corresponding to this row
      let workout = workouts[indexPath.row]
        
      //3. Show the workout's start date in the label
      cell.textLabel?.text = dateFormatter.string(from: workout.startDate)
    
    if let caloriesBurned =
         workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
         let formattedCalories = String(format: "CaloriesBurned: %.2f",
                                        caloriesBurned)
         
         cell.detailTextLabel?.text = formattedCalories
       } else {
         cell.detailTextLabel?.text = nil
       }
       
        
      return cell
    }

}

