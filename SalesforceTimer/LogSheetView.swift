import SwiftUI

struct LogSheetView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        if let context = viewModel.logContext {
            Form {
                Section(header: Text("Details for \(context.workItem.name)")) {
                    HStack {
                        Text("Time to log").foregroundColor(.secondary)
                        Spacer()
                        Text(viewModel.formatTime(context.elapsedTime))
                    }
                    Picker("Agreement", selection: $viewModel.selectedAgreement) {
                        ForEach(viewModel.agreements.filter { agreement in
                            if context.workItem.name == "Internal Work" { return agreement == "Internal Time" }
                            else { return agreement != "Internal Time" }
                        }, id: \.self) { Text($0) }
                    }
                    TextField("Description (required)", text: $viewModel.logDescription)
                    TextField("Kilometers", text: $viewModel.logKilometers)
                    if context.workItem.name != "Internal Work" {
                        Toggle("Out of Scope", isOn: $viewModel.logOutOfScope)
                    }
                }
                Section {
                    Button("Log Time") { viewModel.logCapturedTimeAndReset(); dismiss() }
                        .disabled(viewModel.logDescription.isEmpty)
                    Button("Cancel", role: .destructive) { viewModel.cancelLogging(); dismiss() }
                }
            }
            .padding()
            .frame(minWidth: 400, idealHeight: 450)
            .onAppear {
                if let window = NSApplication.shared.windows.last(where: { $0.isVisible }) {
                    window.makeKeyAndOrderFront(nil)
                }
            }
            .onDisappear {
                viewModel.cancelLogging()
            }
        } else {
            Text("Loading...").onAppear { dismiss() }
        }
    }
}
