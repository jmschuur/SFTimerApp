import SwiftUI

struct ContentView: View {
    @ObservedObject var viewModel: TimerViewModel
    @Environment(\.openWindow) var openWindow

    var body: some View {
        VStack(spacing: 0) {
            // Main Content Area
            HStack(spacing: 0) {
                TimerView(viewModel: viewModel)
                FilterView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.openWindowAction = { id in
                openWindow(id: id)
            }
        }
        .frame(width: 630, height: 450)
    }
}
