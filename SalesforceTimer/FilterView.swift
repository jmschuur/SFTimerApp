import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: TimerViewModel
    
    var body: some View {
        Form {
            Section(header: Text("Filters").padding(.top)) {
                Picker("Owner", selection: $viewModel.ownerFilter) {
                    ForEach(viewModel.ownerOptions, id: \.self) { Text($0) }
                }

                TextField("Account Name", text: $viewModel.accountFilter)

                Picker("Status", selection: $viewModel.statusFilter) {
                    ForEach(viewModel.statusOptions, id: \.self) { Text($0) }
                }

                Picker("Phase", selection: $viewModel.phaseFilter) {
                    ForEach(viewModel.phaseOptions, id: \.self) { Text($0) }
                }

                Picker("Record Type", selection: $viewModel.recordTypeFilter) {
                    ForEach(viewModel.recordTypeOptions, id: \.self) { Text($0) }
                }
            }
        }
        .padding(.horizontal)
        .frame(width: 280)
        .overlay(Rectangle().frame(width: 1, height: nil, alignment: .leading).foregroundColor(Color.gray.opacity(0.2)), alignment: .leading)
    }
}
