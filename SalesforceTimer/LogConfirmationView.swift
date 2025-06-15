import SwiftUI

struct LogConfirmationView: View {
    var body: some View {
        VStack {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 48))
                .foregroundColor(.green)
                .padding(.bottom, 8)
            Text("Time logged successfully!")
                .font(.title2)
                .bold()
            Text("Your work log has been saved.")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(32)
        .frame(minWidth: 300)
    }
}
