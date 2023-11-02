import Cocoa
import FlutterMacOS
import UIKit
import FirebaseCore

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
  override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.dev.myAppRefreshID", using: nil) { task in
            self.handleAppRefresh(task: task as! BGAppRefreshTask)
        }
        return true
  }
  func applicationDidEnterBackground(_ application: UIApplication) {
        scheduleAppRefresh()
    }
    func scheduleAppRefresh() {
       let request = BGAppRefreshTaskRequest(identifier: "com.dev.myAppRefreshID")
       request.earliestBeginDate = Date(timeIntervalSinceNow:0)
       do {
          try BGTaskScheduler.shared.submit(request)
       } catch {
          print("Could not schedule app refresh: \(error)")
       }
    }
    
    func handleAppRefresh(task: BGAppRefreshTask) {
        print("Refresh called")
        scheduleAppRefresh()
        let operationQueue = OperationQueue()
        let refreshOperation = BlockOperation {
            let refreshManager = BackgroundRefresh()
            refreshManager.updateInfoForServer()
            print("Refresh executed")
        }
        task.expirationHandler = { refreshOperation.cancel() }
        refreshOperation.completionBlock = {
            task.setTaskCompleted(success: !refreshOperation.isCancelled)
        }
        operationQueue.addOperation(refreshOperation)
    }
}
