//  HomeView.swift
//  Charikawa
//  Created by Bhagya Deepathi – IT22306890 on 2025-11-10
//  Description: Displays the main landing screen with animations, logo, and navigation to map/gallery.

import SwiftUI
import CoreMotion

struct HomeView: View {
    // MARK: - Properties
    @EnvironmentObject var memoryVM: MemoryViewModel
    @State private var showHeader = false
    @State private var showButton = false
    @State private var animatePlane = false
    @State private var animatePin = false
    @State private var globeSpin = false
    @State private var animationsEnabled = true
    @State private var animateClouds = false
    @State private var animatePlane2 = false
    @State private var pulseCompass = false
    @State private var twinkle = false
    @State private var glowPulse = false
    private let motionManager = CMMotionManager()
    @State private var parallaxX: CGFloat = 0
    @State private var parallaxY: CGFloat = 0
    @State private var nudge: CGFloat = 0

    // MARK: - Body
    /// Renders the animated home screen with logo, tagline, and primary navigation button.
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.835, blue: 0.502), // #FFD580
                        Color(red: 0.424, green: 0.388, blue: 1.0)   // #6C63FF
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                // Animated stickers layer (background)
                if animationsEnabled {
                    ZStack {
                        // Floating airplane
                        Image(systemName: "airplane")
                            .font(.system(size: 34, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.85))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 3)
                            .rotationEffect(.degrees(-10))
                            .offset(x: animatePlane ? 180 : -180, y: -140)
                            .opacity(0.55)
                            .animation(.easeInOut(duration: 6).repeatForever(autoreverses: true), value: animatePlane)

                        // Bouncing map pin
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 28, weight: .regular))
                            .foregroundStyle(.red.opacity(0.9))
                            .offset(x: -120, y: animatePin ? -8 : 8)
                            .opacity(0.8)
                            .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true), value: animatePin)

                        // Subtle rotating globe
                        Image(systemName: "globe.americas.fill")
                            .font(.system(size: 120))
                            .foregroundStyle(.white.opacity(0.08))
                            .rotationEffect(.degrees(globeSpin ? 360 : 0))
                            .animation(.linear(duration: 28).repeatForever(autoreverses: false), value: globeSpin)
                            .offset(y: 200)

                        // Drifting clouds
                        Group {
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(.white.opacity(0.25))
                                .offset(x: animateClouds ? 220 : -220, y: -60)
                                .animation(.linear(duration: 22).repeatForever(autoreverses: true), value: animateClouds)
                            Image(systemName: "cloud.fill")
                                .font(.system(size: 36))
                                .foregroundStyle(.white.opacity(0.2))
                                .offset(x: animateClouds ? -240 : 240, y: -10)
                                .animation(.linear(duration: 26).repeatForever(autoreverses: true), value: animateClouds)
                        }

                        // Second paper plane sweeping across
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(.white.opacity(0.8))
                            .rotationEffect(.degrees(12))
                            .offset(x: animatePlane2 ? -170 : 170, y: 100)
                            .opacity(0.5)
                            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animatePlane2)

                        // Pulsing compass
                        Image(systemName: "location.north.circle.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.white.opacity(0.85))
                            .scaleEffect(pulseCompass ? 1.05 : 0.92)
                            .opacity(0.65)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: pulseCompass)
                            .offset(x: 130, y: 160)

                        
                        Group {
                            Circle().fill(Color.white.opacity(0.7)).frame(width: 2, height: 2)
                                .opacity(twinkle ? 1.0 : 0.3)
                                .offset(x: -150, y: -200)
                                .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(0.1), value: twinkle)
                            Circle().fill(Color.white.opacity(0.7)).frame(width: 2, height: 2)
                                .opacity(twinkle ? 1.0 : 0.3)
                                .offset(x: 80, y: -180)
                                .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true).delay(0.3), value: twinkle)
                            Circle().fill(Color.white.opacity(0.7)).frame(width: 2, height: 2)
                                .opacity(twinkle ? 1.0 : 0.3)
                                .offset(x: -60, y: -140)
                                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.5), value: twinkle)
                            Circle().fill(Color.white.opacity(0.7)).frame(width: 2, height: 2)
                                .opacity(twinkle ? 1.0 : 0.3)
                                .offset(x: 150, y: -120)
                                .animation(.easeInOut(duration: 1.3).repeatForever(autoreverses: true).delay(0.2), value: twinkle)
                            Circle().fill(Color.cyan.opacity(0.9)).frame(width: 3, height: 3)
                                .opacity(twinkle ? 1.0 : 0.2)
                                .scaleEffect(twinkle ? 1.2 : 0.8)
                                .offset(x: -20, y: -10)
                                .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true).delay(0.15), value: twinkle)
                            Circle().fill(Color.pink.opacity(0.9)).frame(width: 3, height: 3)
                                .opacity(twinkle ? 1.0 : 0.2)
                                .scaleEffect(twinkle ? 1.15 : 0.85)
                                .offset(x: 26, y: -6)
                                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.35), value: twinkle)
                            Circle().fill(Color.blue.opacity(0.9)).frame(width: 2.5, height: 2.5)
                                .opacity(twinkle ? 1.0 : 0.2)
                                .scaleEffect(twinkle ? 1.1 : 0.9)
                                .offset(x: 0, y: 40)
                                .animation(.easeInOut(duration: 1.6).repeatForever(autoreverses: true).delay(0.25), value: twinkle)
                        }
                    }
                    .offset(x: parallaxX + nudge, y: parallaxY)
                    .allowsHitTesting(false)
                }

                VStack(spacing: 16) {
                    Spacer()

                    Image("CharikawaLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 220, height: 220)
                        .shadow(color: .black.opacity(0.25), radius: 10, x: 0, y: 6)
                        .opacity(showHeader ? 1 : 0)
                        .scaleEffect(showHeader ? 1.0 : 0.96)
                        .animation(.easeOut(duration: 0.6).delay(0.05), value: showHeader)

                    Text("Charikawa")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 4)
                        .opacity(showHeader ? 1 : 0)
                        .offset(y: showHeader ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.12), value: showHeader)

                    Text("Your Journey, Pinned Beautifully.")
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.white.opacity(0.95))
                        .shadow(color: .black.opacity(0.2), radius: 6, x: 0, y: 3)
                        .opacity(showHeader ? 1 : 0)
                        .offset(y: showHeader ? 0 : 10)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: showHeader)

                    Spacer().frame(height: 32)

                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(
                                RadialGradient(colors: [
                                    Color.cyan.opacity(0.35),
                                    Color.blue.opacity(0.22),
                                    Color.pink.opacity(0.18),
                                    Color.clear
                                ], center: .center, startRadius: 10, endRadius: 180)
                            )
                            .scaleEffect(glowPulse ? 1.05 : 0.95)
                            .opacity(glowPulse ? 0.9 : 0.7)
                            .animation(.easeInOut(duration: 1.8).repeatForever(autoreverses: true), value: glowPulse)

                        NavigationLink(value: Route.map) {
                            Text("Start Exploring")
                                .font(.headline)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 18)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.white.opacity(0.22),
                                                    Color.white.opacity(0.10)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    ZStack {
                                        // Outer bevel strokes
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.6), Color.white.opacity(0.2)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 1.25
                                            )
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.5)],
                                                    startPoint: .bottomTrailing,
                                                    endPoint: .topLeading
                                                ),
                                                lineWidth: 0.9
                                            )
                                            .blendMode(.overlay)

                                        // Inner highlight (top-left)
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.white.opacity(0.45), lineWidth: 1.2)
                                            .blur(radius: 1)
                                            .offset(x: -1, y: -1)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [Color.white, .clear],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )

                                        // Inner shadow (bottom-right)
                                        RoundedRectangle(cornerRadius: 18)
                                            .stroke(Color.black.opacity(0.35), lineWidth: 1.4)
                                            .blur(radius: 1.2)
                                            .offset(x: 1.2, y: 1.2)
                                            .mask(
                                                RoundedRectangle(cornerRadius: 18)
                                                    .fill(
                                                        LinearGradient(
                                                            colors: [.clear, Color.black],
                                                            startPoint: .topLeading,
                                                            endPoint: .bottomTrailing
                                                        )
                                                    )
                                            )
                                    }
                                )
                                .foregroundStyle(.white)
                                .cornerRadius(18)
                                // Dual-direction outer shadows for stronger emboss
                                .shadow(color: .white.opacity(0.35), radius: 1.0, x: -1, y: -1)
                                .shadow(color: .black.opacity(0.35), radius: 2.0, x: 2, y: 2)
                                // Existing colorful glows
                                .shadow(color: .cyan.opacity(0.55), radius: glowPulse ? 22 : 12)
                                .shadow(color: .pink.opacity(0.35), radius: glowPulse ? 28 : 14)
                                .shadow(color: .blue.opacity(0.25), radius: glowPulse ? 18 : 10)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(showButton ? 1 : 0)
                    .offset(y: showButton ? 0 : 10)
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: showButton)

                    Spacer()
                }
                .padding()
                .scaleEffect(showHeader ? 1.0 : 0.98)
                .opacity(showHeader ? 1.0 : 0.6)
                .animation(.easeOut(duration: 0.8), value: showHeader)
                .offset(x: -parallaxX * 0.18, y: -parallaxY * 0.18)
            }
            .toolbar(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Toggle(isOn: $animationsEnabled) {
                        Label("Animations", systemImage: animationsEnabled ? "sparkles" : "pause.circle")
                    }
                    .toggleStyle(.switch)
                }
            }
            // MARK: - Lifecycle
            .onAppear {
                showHeader = true
                showButton = true
                animatePlane = true
                animatePin = true
                globeSpin = true
                animateClouds = true
                animatePlane2 = true
                pulseCompass = true
                twinkle = true
                glowPulse = true
                startMotion()
            }
            .onDisappear { stopMotion() }
            // MARK: - Actions
            .onTapGesture {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { nudge = 14 }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { nudge = 0 }
                }
                restartAnimations()
            }
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .map:
                    MapView()
                case .add:
                    AddMemoryView()
                case .gallery:
                    GalleryView()
                }
            }
        }
    }
}

private extension HomeView {
    // MARK: - Motion / Parallax
    /// Starts device motion updates to drive a subtle parallax effect.
    /// - Side effects: Updates `parallaxX` and `parallaxY` continuously on main thread.
    func startMotion() {
        guard motionManager.isDeviceMotionAvailable else { return }
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { motion, _ in
            guard let m = motion else { return }
            let roll = CGFloat(m.attitude.roll)
            let pitch = CGFloat(m.attitude.pitch)
            parallaxX = roll * 14
            parallaxY = -pitch * 14
        }
    }

    /// Stops device motion updates and resets parallax values.
    /// - Side effects: Sets `parallaxX` and `parallaxY` to zero.
    func stopMotion() {
        motionManager.stopDeviceMotionUpdates()
        parallaxX = 0
        parallaxY = 0
    }

    /// Reaffirms animation state flags to ensure continuous animations after interactions.
    /// - Side effects: Sets animation booleans to true to resume repeating animations.
    func restartAnimations() {
        animatePlane = true
        animatePin = true
        globeSpin = true
        animateClouds = true
        animatePlane2 = true
        pulseCompass = true
        twinkle = true
        glowPulse = true
    }
}

enum Route: Hashable {
    case map
    case add
    case gallery
}

#Preview {
    HomeView()
        .environmentObject(MemoryViewModel(persistence: .preview))
}
