import SwiftUI

struct SplashScreenView : View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
            Spacer()
        }.tint(Color(hex: "4ECDC4"))
    }
}
