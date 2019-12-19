

import UIKit
import FirebaseAnalytics
import FirebaseFirestore
import Firebase


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       FirebaseApp.configure()
       let locationManager = LocationManager.shared
       locationManager.requestWhenInUseAuthorization()
       return true
     }
     
     func applicationDidEnterBackground(_ application: UIApplication) {
       CoreDataStack.saveContext()
     }
     
     func applicationWillTerminate(_ application: UIApplication) {
       CoreDataStack.saveContext()
     }
     
}

