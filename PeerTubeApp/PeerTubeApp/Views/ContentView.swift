//
//  ContentView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		NavigationView {
			VStack {
				Image(systemName: "play.tv")
					.imageScale(.large)
					.foregroundColor(.accentColor)
					.font(.system(size: 60))

				Text("PeerTube")
					.font(.largeTitle)
					.fontWeight(.bold)
					.padding()

				Text("Decentralized Video Platform")
					.font(.subheadline)
					.foregroundColor(.secondary)

				Spacer()
					.frame(height: 50)

				VStack(spacing: 20) {
					Text("Welcome to PeerTube!")
						.font(.title2)
						.fontWeight(.medium)

					Text("This is a basic iOS client for browsing PeerTube instances.")
						.multilineTextAlignment(.center)
						.foregroundColor(.secondary)
						.padding(.horizontal)

					Button("Get Started") {
						// TODO: Add functionality
					}
					.buttonStyle(.borderedProminent)
					.controlSize(.large)
				}

				Spacer()
			}
			.padding()
			.navigationTitle("PeerTube")
			.navigationBarHidden(true)
		}
	}
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		ContentView()
	}
}
