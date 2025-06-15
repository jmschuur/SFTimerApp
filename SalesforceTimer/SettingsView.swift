import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        Form {
            Section(header: Text("Time Rounding")) {
                Picker("Round time to (minutes)", selection: $viewModel.roundingInterval) {
                    ForEach(viewModel.roundingIntervalOptions, id: \.self) { Text("\($0)") }
                }
                
                Picker("Rounding direction", selection: $viewModel.roundingDirection) {
                    ForEach(viewModel.roundingDirectionOptions, id: \.self) { Text($0) }
                }
            }
            
            Section(header: Text("Idle Detection")) {
                Toggle("Enable Idle Timer", isOn: $viewModel.isIdleTimerEnabled)
                
                if viewModel.isIdleTimerEnabled {
                    Stepper("Prompt after \(viewModel.idleTimeMinutes) minutes of inactivity", value: $viewModel.idleTimeMinutes, in: 1...60)
                }
            }
            Section {
                HStack {
                    Spacer()
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .padding()
        .frame(minWidth: 350)
        .onAppear {
            if let window = NSApplication.shared.windows.last(where: { $0.isVisible }) {
                window.makeKeyAndOrderFront(nil)
            }
        }
    }
}
