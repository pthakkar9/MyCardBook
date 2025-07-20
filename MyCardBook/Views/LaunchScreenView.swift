import SwiftUI

struct LaunchScreenView: View {
    @State private var isAnimating = false
    @State private var opacity = 0.0
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.0, green: 0.478, blue: 1.0), // iOS Blue
                    Color(red: 0.2, green: 0.6, blue: 1.0)   // Lighter blue
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 32) {
                // App Icon
                ZStack {
                    // Background circle
                    Circle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 140, height: 140)
                    
                    // Card stack icon
                    VStack(spacing: -8) {
                        // Back cards
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.3))
                            .frame(width: 70, height: 45)
                            .rotationEffect(.degrees(-5))
                            .offset(x: -8, y: 8)
                        
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 70, height: 45)
                            .rotationEffect(.degrees(2))
                            .offset(x: 4, y: 4)
                        
                        // Front card
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(width: 70, height: 45)
                            .overlay(
                                VStack(spacing: 4) {
                                    // Card details
                                    HStack {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 8, height: 8)
                                        Spacer()
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 6, height: 6)
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.top, 6)
                                    
                                    Spacer()
                                    
                                    // Card number representation
                                    HStack(spacing: 2) {
                                        ForEach(0..<4) { _ in
                                            RoundedRectangle(cornerRadius: 1)
                                                .fill(Color.blue.opacity(0.6))
                                                .frame(width: 8, height: 2)
                                        }
                                    }
                                    .padding(.bottom, 6)
                                }
                            )
                            .scaleEffect(isAnimating ? 1.1 : 1.0)
                            .animation(
                                Animation.easeInOut(duration: 1.5)
                                    .repeatForever(autoreverses: true),
                                value: isAnimating
                            )
                    }
                }
                
                // App Name and Tagline
                VStack(spacing: 12) {
                    Text("MyCardBook")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(opacity)
                    
                    Text("Never lose a credit again")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                opacity = 1.0
            }
            
            withAnimation(.easeInOut(duration: 1.5).delay(0.5)) {
                isAnimating = true
            }
        }
    }
}

struct LaunchScreenView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchScreenView()
    }
}