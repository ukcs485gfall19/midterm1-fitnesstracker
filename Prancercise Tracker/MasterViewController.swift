
import Foundation

import UIKit

class MasterViewController: UITableViewController {
  
  private let authorizeHealthKitSection = 2
  
  private func authorizeHealthKit() {

  }
  
  // MARK: - UITableView Delegate
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.section == authorizeHealthKitSection {
      authorizeHealthKit()
    }
  }
}
