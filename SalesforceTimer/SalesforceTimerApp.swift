import SwiftUI

@main
struct SalesforceTimerApp: App {
    @StateObject private var viewModel = TimerViewModel()

    var body: some Scene {
        Window("Salesforce Timer", id: "main-window") {
            ContentView(viewModel: viewModel)
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)

        MenuBarExtra {
            MenuBarMenu(viewModel: viewModel)
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "clock")
                Text(viewModel.formatTime(viewModel.elapsedTime))
                    .font(.system(.body, design: .monospaced))
                    .foregroundStyle(viewModel.timerIsRunning ? .primary : .secondary)
            }
        }

        WindowGroup("Log Time", id: "log-sheet-window") {
            LogSheetView(viewModel: viewModel)
        }

        WindowGroup("Settings", id: "settings-window") {
            SettingsView(viewModel: viewModel)
        }

        .windowStyle(.plain)
        .windowResizability(.contentSize)
    }
}

struct MenuBarMenu: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        if viewModel.timerIsRunning, let active = viewModel.activeWorkItem {
            Button("Timer running for: \(active.name)") {
                openWindow(id: "main-window")
            }
        } else {
            Button("No timer running") {
                openWindow(id: "main-window")
            }
        }
        Divider()
        Button("Show Timer Window") {
            openWindow(id: "main-window")
        }
        Button("Settings...") {
            openWindow(id: "settings-window")
        }
        Divider()
        Button("Quit Salesforce Timer") {
            NSApplication.shared.terminate(nil)
        }
    }
}
