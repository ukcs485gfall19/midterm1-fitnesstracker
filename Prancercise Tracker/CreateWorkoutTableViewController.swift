
import UIKit
import MapKit
import CoreLocation
import Firebase

class CreateWorkoutTableViewController: UITableViewController {
  @IBOutlet private var startTimeLabel: UILabel!
  @IBOutlet private var durationLabel: UILabel!
    
  
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var MapView: MKMapView!
    
   private var run: Run?
   private let locationManager = LocationManager.shared
   private var seconds = 0
   private var timer: Timer?
   private var distance = Measurement(value: 0, unit: UnitLength.meters)
   private var locationList: [CLLocation] = []
  private var polyline: MKPolyline?
  
  var session = WorkoutSession()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
      self.updateLabels()
    }
  }
  
  private func updateOKButtonStatus() {
    var isEnabled = false
    
    switch session.state {
    case .notStarted, .active:
      isEnabled = false
    case .finished:
      isEnabled = true
    }
    
    navigationItem.rightBarButtonItem?.isEnabled = isEnabled
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    session.clear()
    updateOKButtonStatus()
  }
  
  private lazy var startTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter
  }()
  
  private lazy var durationFormatter: DateComponentsFormatter = {
    let formatter = DateComponentsFormatter()
    formatter.unitsStyle = .positional
    formatter.allowedUnits = [.minute, .second]
    formatter.zeroFormattingBehavior = [.pad]
    return formatter
  }()
  
  func updateLabels() {
    switch session.state {
    case .active:
      startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
      let duration = Date().timeIntervalSince(session.startDate)
      durationLabel.text = durationFormatter.string(from: duration)
    case .finished:
      startTimeLabel.text = startTimeFormatter.string(from: session.startDate)
      let duration = session.endDate.timeIntervalSince(session.startDate)
      durationLabel.text = durationFormatter.string(from: duration)
    default:
      startTimeLabel.text = nil
      durationLabel.text = nil
    }
  }
  
  //MARK: UITableView Datasource
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch session.state {
    case .active, .finished:
      return 2
    case .notStarted:
      return 0
    }
  }
  
  //MARK: UITableView Delegate
  override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    var buttonTitle: String!
    var buttonColor: UIColor!
    
    switch session.state {
    case .active:
      buttonTitle = "STOP EXERCISE"
      buttonColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
    case .notStarted:
      buttonTitle = "START EXERCISING!"
      buttonColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    case .finished:
      buttonTitle = "NEW EXERCISE"
      buttonColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
    }
    
    let buttonFrame = CGRect(x: 0, y: 0,
                             width: tableView.frame.size.width,
                             height: 44.0)
    
    let button = UIButton(frame: buttonFrame)
    button.setTitle(buttonTitle, for: .normal)
    button.addTarget(self,
                     action: #selector(startStopButtonPressed),
                     for: .touchUpInside)
    button.backgroundColor = buttonColor
    return button
  }
  
  override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 44.0
  }
  
  func beginWorkout() {
    
    session.start()
    updateLabels()
    mapContainerView.isHidden = false
    updateOKButtonStatus()
    tableView.reloadData()
    MapView.removeOverlays(MapView.overlays)
    seconds = 0
    distance = Measurement(value: 0, unit: UnitLength.meters)
    locationList.removeAll()
    startLocationUpdates()
    
  }
  
  func finishWorkout() {
    session.end()
    updateLabels()
    updateOKButtonStatus()
    tableView.reloadData()
    locationManager.stopUpdatingLocation()
    sendtoFireStore()
  }
  
  @objc func startStopButtonPressed() {
    switch session.state {
    case .notStarted, .finished:
      displayStartWorkoutAlert()
    case .active:
      finishWorkout()
    }
  }
    
    private func startLocationUpdates() {
      locationManager.delegate = self
      locationManager.activityType = .fitness
      locationManager.distanceFilter = 10
      locationManager.startUpdatingLocation()
    }
  
  @IBAction func cancelButtonPressed(sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func doneButtonPressed(sender: Any) {
    guard let currentWorkout = session.completeWorkout else {
      fatalError("Shouldn't be able to press the done button without a saved workout.")
    }
    
    WorkoutDataStore.save(OneHourWalker: currentWorkout) { (success, error) in
      if success {
        self.dismissAndRefreshWorkouts()
        
      } else {
        self.displayProblemSavingWorkoutAlert()
      }
    }
  }
  
  private func dismissAndRefreshWorkouts() {
    session.clear()
    //This is causing an issue when finishing a run
    DispatchQueue.main.sync {
    self.dismiss(animated: true, completion: nil)
  }
    }
    
    private func sendtoFireStore() {
        let db = Firestore.firestore()
        var lats = [Double]()
        var longs = [Double]()
        for location in locationList {
            lats.append(location.coordinate.latitude)
            longs.append(location.coordinate.longitude)
            
        }
        db.collection("Locations").document().setData(["longitude":longs, "latitude":lats])
    }
    
    
  
  private func displayStartWorkoutAlert() {
    let alert = UIAlertController(title: nil,
                                  message: "Start an exercise session? ",
                                  preferredStyle: .alert)
    let yesAction = UIAlertAction(title: "Yes",
                                  style: .default) { (action) in
                                    self.beginWorkout()
    }
    
    let noAction = UIAlertAction(title: "No",
                                 style: .cancel,
                                 handler: nil)
    alert.addAction(yesAction)
    alert.addAction(noAction)
    present(alert, animated: true, completion: nil)
  }
  
  private func displayProblemSavingWorkoutAlert() {
    let alert = UIAlertController(title: nil,
                                  message: "There was a problem saving your workout",
                                  preferredStyle: .alert)
    let okayAction = UIAlertAction(title: "O.K.",
                                   style: .default,
                                   handler: nil)
    alert.addAction(okayAction)
    present(alert, animated: true, completion: nil)
  }
    
}



// MARK: - Location Manager Delegate
extension CreateWorkoutTableViewController: CLLocationManagerDelegate {
  
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    for newLocation in locations {
      let howRecent = newLocation.timestamp.timeIntervalSinceNow
      guard newLocation.horizontalAccuracy < 20 && abs(howRecent) < 10 else { continue }
      
      if let lastLocation = locationList.last {
        let delta = newLocation.distance(from: lastLocation)
        distance = distance + Measurement(value: delta, unit: UnitLength.meters)
        let coordinates = [lastLocation.coordinate, newLocation.coordinate]
        MapView.addOverlay(MKPolyline(coordinates: coordinates, count: 2))
        let region = MKCoordinateRegion.init(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        MapView.setRegion(region, animated: true)
      }
      
      locationList.append(newLocation)
    }
  }
}

// MARK: - Map View Delegate

extension CreateWorkoutTableViewController: MKMapViewDelegate {
    private func MapView(_ MapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
    guard let polyline = overlay as? MKPolyline else {
      return MKOverlayRenderer(overlay: overlay)
    }
    let renderer = MKPolylineRenderer(polyline: polyline)
    renderer.strokeColor = .blue
    renderer.lineWidth = 3
    return renderer
  }
}
