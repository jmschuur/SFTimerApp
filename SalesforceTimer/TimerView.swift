import SwiftUI

// The main timer view with the list
struct TimerView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            VStack {
                Text(viewModel.formatTime(viewModel.elapsedTime))
                    .font(.system(size: 40, weight: .bold, design: .monospaced))
                
                Text(viewModel.activeWorkItem?.name ?? "Select a Work Item")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .padding(.top, 20)

            HStack {
                Button("Start", systemImage: "play.fill") { viewModel.startTimer() }
                    .buttonStyle(.borderedProminent).tint(.green)
                    .disabled(viewModel.activeWorkItem == nil || viewModel.timerIsRunning)
                
                Button("Stop & Log", systemImage: "stop.fill") { viewModel.prepareToLog() }
                    .buttonStyle(.borderedProminent).tint(.red)
                    .disabled(!viewModel.timerIsRunning)
            }
            
            Divider()

            HStack {
                Text("Work Items").font(.headline)
                Spacer()
                Link(destination: URL(string: "https://nu.nl")!) {
                    Image(systemName: "plus.circle.fill")
                }
                .buttonStyle(.borderless).help("Create new Work Item")
            }

            List(viewModel.filteredWorkItems) { item in
                HStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name).fontWeight(.medium)
                            if item.name != "Internal Work" {
                                HStack(spacing: 12) {
                                    Label(String(format: "%.2fh", item.myHours), systemImage: "person.fill")
                                    Label(String(format: "%.2fh", item.totalHours), systemImage: "person.3.fill")
                                    Label(String(format: "%.2fh", item.estimatedHours), systemImage: "target")
                                        .foregroundColor(progressColor(for: item))
                                }
                                .font(.caption).foregroundColor(.secondary)
                            }
                        }
                        Spacer()
                        if viewModel.activeWorkItem == item {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.green)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { viewModel.selectWorkItem(for: item) }
                    .disabled(viewModel.timerIsRunning)
                    .opacity(viewModel.timerIsRunning ? 0.5 : 1.0)

                    Link(destination: URL(string: "https://www.salesforce.com")!) {
                        Image(systemName: "arrow.up.right.square")
                    }
                    .buttonStyle(.borderless).padding(.leading, 5)
                }
                .padding(.vertical, 4)
            }
            .listStyle(.plain)
        }
        .padding()
        .frame(width: 350)
    }
    
    private func progressColor(for item: WorkItem) -> Color {
        guard item.estimatedHours > 0 else { return .secondary }
        let percentage = item.totalHours / item.estimatedHours
        if percentage > 1.0 { return .red }
        else if percentage >= 0.75 { return .orange }
        else { return .green }
    }
}
