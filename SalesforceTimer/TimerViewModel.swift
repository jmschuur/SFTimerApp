import Foundation
import SwiftUI

// A simple model for a Work Item, now with all filterable fields.
struct WorkItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let myHours: Double
    let totalHours: Double
    let estimatedHours: Double
    
    // Fields for the filters
    let owner: String
    let accountName: String
    let status: String
    let phase: String
    let recordType: String
}

// A struct to hold the details for the log form.
struct LogContext {
    let workItem: WorkItem
    let elapsedTime: TimeInterval
}

// The ViewModel that manages all logic and data for our timer.
class TimerViewModel: ObservableObject {
    // Timer status
    @Published var timerIsRunning = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var activeWorkItem: WorkItem?
    
    // UI status
    @Published var logContext: LogContext?

    // Filter Status with persistence
    @AppStorage("filter_owner") var ownerFilter: String = "My Work Items"
    @AppStorage("filter_account") var accountFilter: String = ""
    @AppStorage("filter_status") var statusFilter: String = "All"
    @AppStorage("filter_phase") var phaseFilter: String = "All"
    @AppStorage("filter_recordType") var recordTypeFilter: String = "All"
    
    // Settings with persistence
    @AppStorage("settings_roundingInterval") var roundingInterval: Int = 15
    @AppStorage("settings_roundingDirection") var roundingDirection: String = "Up"
    @AppStorage("settings_isIdleTimerEnabled") var isIdleTimerEnabled: Bool = false
    @AppStorage("settings_idleTimeMinutes") var idleTimeMinutes: Int = 10

    // Status for the Log Form
    @Published var selectedAgreement: String = ""
    @Published var logDescription: String = ""
    @Published var logKilometers: String = ""
    @Published var logOutOfScope: Bool = false
    
    private var timer: Timer?
    private var startTime: Date?

    // Dummy data
    let allWorkItems: [WorkItem] = [
        WorkItem(name: "Internal Work", myHours: 0, totalHours: 0, estimatedHours: 0, owner: "Me", accountName: "Own Company", status: "In Progress", phase: "Execution", recordType: "Internal"),
        WorkItem(name: "WI-0123: Fix bug in checkout", myHours: 2.5, totalHours: 6.0, estimatedHours: 10.0, owner: "Me", accountName: "Client A", status: "In Progress", phase: "Execution", recordType: "Bug"),
        WorkItem(name: "WI-0456: New homepage feature", myHours: 5.0, totalHours: 12.0, estimatedHours: 15.0, owner: "Me", accountName: "Client B", status: "New", phase: "Analysis", recordType: "User Story"),
        WorkItem(name: "WI-1011: Urgent data recovery", myHours: 6.0, totalHours: 9.0, estimatedHours: 8.0, owner: "Colleague", accountName: "Client A", status: "Blocked", phase: "Execution", recordType: "Bug"),
        WorkItem(name: "WI-0789: Meeting with client X", myHours: 0.75, totalHours: 0.75, estimatedHours: 1.0, owner: "Me", accountName: "Client X", status: "Done", phase: "Closing", recordType: "Task")
    ]
    let agreements = ["Hour Bundle A", "Project X", "Time & Materials 2024", "Internal Time"]

    // Options for the pickers
    let ownerOptions = ["My Work Items", "All Work Items"]
    let statusOptions = ["All", "New", "In Progress", "Blocked", "Done"]
    let phaseOptions = ["All", "Analysis", "Execution", "Closing"]
    let recordTypeOptions = ["All", "User Story", "Bug", "Task", "Internal"]
    let roundingIntervalOptions = [1, 5, 10, 15, 30]
    let roundingDirectionOptions = ["Up", "Down", "Nearest"]

    var filteredWorkItems: [WorkItem] {
        allWorkItems.filter { item in
            let ownerMatch = (ownerFilter == "All Work Items") || (item.owner == "Me")
            let accountMatch = accountFilter.isEmpty || item.accountName.localizedCaseInsensitiveContains(accountFilter)
            let statusMatch = (statusFilter == "All") || (item.status == statusFilter)
            let phaseMatch = (phaseFilter == "All") || (item.phase == phaseFilter)
            let recordTypeMatch = (recordTypeFilter == "All") || (item.recordType == recordTypeFilter)
            
            return ownerMatch && accountMatch && statusMatch && phaseMatch && recordTypeMatch
        }
    }

    // Actions to be linked by the App Delegate and Views
    var openWindowAction: ((String) -> Void)?
    var showMainWindowAction: (() -> Void)?
    
    // Function to be called from the MenuBarExtra
    func showMainWindow() {
        showMainWindowAction?()
    }
    
    func selectWorkItem(for workItem: WorkItem) {
        guard !timerIsRunning else { return }
        activeWorkItem = workItem
        elapsedTime = 0
    }
    
    func startTimer() {
        guard activeWorkItem != nil, !timerIsRunning else { return }
        startTime = Date()
        timerIsRunning = true
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.startTime else { return }
            self.elapsedTime = Date().timeIntervalSince(startTime)
        }
    }

    func prepareToLog() {
        guard let itemToLog = activeWorkItem, timerIsRunning else { return }
        
        let timeToLog = getRoundedTime(elapsedTime)
        
        logContext = LogContext(workItem: itemToLog, elapsedTime: timeToLog)
        
        if itemToLog.name == "Internal Work" {
            selectedAgreement = "Internal Time"
        } else {
            selectedAgreement = agreements.first(where: { $0 != "Internal Time" }) ?? ""
        }
        logDescription = ""
        logKilometers = ""
        logOutOfScope = false
        openWindowAction?("log-sheet-window")
    }
    
    func logCapturedTimeAndReset() {
        guard let context = logContext else { return }
        print("--- TIME LOGGED ---")
        print("Work Item: \(context.workItem.name)")
        print("Duration (hours): \(String(format: "%.2f", (context.elapsedTime / 3600)))")
        timer?.invalidate()
        timer = nil
        timerIsRunning = false
        activeWorkItem = nil
        elapsedTime = 0
        logContext = nil
    }

    func cancelLogging() {
        logContext = nil
    }
    
    func getRoundedTime(_ interval: TimeInterval) -> TimeInterval {
        let intervalInMinutes = interval / 60
        let roundingMinutes = Double(roundingInterval)
        
        switch roundingDirection {
        case "Up":
            return ceil(intervalInMinutes / roundingMinutes) * roundingMinutes * 60
        case "Down":
            return floor(intervalInMinutes / roundingMinutes) * roundingMinutes * 60
        case "Nearest":
            return round(intervalInMinutes / roundingMinutes) * roundingMinutes * 60
        default:
            return interval
        }
    }
    
    func formatTime(_ interval: TimeInterval) -> String {
        let hours = Int(interval) / 3600
        let minutes = Int(interval) / 60 % 60
        let seconds = Int(interval) % 60
        return String(format:"%02i:%02i:%02i", hours, minutes, seconds)
    }
}

