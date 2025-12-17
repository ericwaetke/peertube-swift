//
//  AboutView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import SwiftUI

struct AboutView: View {

	// MARK: - Properties

	@EnvironmentObject private var appState: AppState

	private let appVersion =
		Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
	private let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"

	// MARK: - Body

	var body: some View {
		ScrollView {
			VStack(spacing: 24) {
				// App icon and title
				appHeaderSection

				// Version info
				versionInfoSection

				// Description
				descriptionSection

				// Links section
				linksSection

				// Credits section
				creditsSection

				// Legal section
				legalSection

				Spacer(minLength: 32)
			}
			.padding()
		}
		.navigationTitle("About")
		.navigationBarTitleDisplayMode(.inline)
	}

	// MARK: - Sections

	private var appHeaderSection: some View {
		VStack(spacing: 16) {
			// App icon placeholder
			RoundedRectangle(cornerRadius: 20)
				.fill(Color.accentColor)
				.frame(width: 80, height: 80)
				.overlay(
					Image(systemName: "play.tv")
						.font(.largeTitle)
						.foregroundColor(.white)
				)

			VStack(spacing: 4) {
				Text("PeerTube")
					.font(.title)
					.fontWeight(.bold)

				Text("Decentralized Video Platform")
					.font(.subheadline)
					.foregroundColor(.secondary)
			}
		}
	}

	private var versionInfoSection: some View {
		VStack(spacing: 8) {
			InfoRowView(
				title: "Version",
				value: appVersion
			)

			InfoRowView(
				title: "Build",
				value: buildNumber
			)

			if let currentInstance = appState.currentInstance {
				InfoRowView(
					title: "Connected Instance",
					value: currentInstance.host
				)
			}
		}
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}

	private var descriptionSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("About PeerTube")
				.font(.headline)

			Text(
				"""
				PeerTube is a free and decentralized alternative to video platforms, providing you sovereignty over your data. This app allows you to browse, watch, and interact with content from the PeerTube network.

				Each PeerTube instance is independently hosted and moderated, creating a diverse ecosystem of communities around the world.
				"""
			)
			.font(.body)
			.fixedSize(horizontal: false, vertical: true)
		}
	}

	private var linksSection: some View {
		VStack(spacing: 12) {
			Text("Learn More")
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)

			VStack(spacing: 8) {
				LinkRowView(
					title: "PeerTube Website",
					subtitle: "Official project website",
					systemImage: "globe",
					action: {
						openURL("https://joinpeertube.org")
					}
				)

				LinkRowView(
					title: "Find Instances",
					subtitle: "Discover PeerTube instances",
					systemImage: "magnifyingglass",
					action: {
						openURL("https://instances.joinpeertube.org")
					}
				)

				LinkRowView(
					title: "Source Code",
					subtitle: "View on GitHub",
					systemImage: "chevron.left.forwardslash.chevron.right",
					action: {
						// TODO: Replace with actual GitHub URL
						openURL("https://github.com")
					}
				)
			}
		}
	}

	private var creditsSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Credits")
				.font(.headline)

			VStack(alignment: .leading, spacing: 8) {
				Text("Built with ❤️ using SwiftUI")
					.font(.body)

				Text("PeerTube is developed by Framasoft")
					.font(.body)

				Text("Special thanks to the open source community")
					.font(.body)
			}
		}
	}

	private var legalSection: some View {
		VStack(spacing: 12) {
			Text("Legal")
				.font(.headline)
				.frame(maxWidth: .infinity, alignment: .leading)

			VStack(spacing: 8) {
				LinkRowView(
					title: "Privacy Policy",
					subtitle: "How we handle your data",
					systemImage: "hand.raised",
					action: {
						// TODO: Add privacy policy URL
					}
				)

				LinkRowView(
					title: "Terms of Service",
					subtitle: "Usage terms and conditions",
					systemImage: "doc.text",
					action: {
						// TODO: Add terms of service URL
					}
				)

				LinkRowView(
					title: "Open Source Licenses",
					subtitle: "Third-party acknowledgments",
					systemImage: "books.vertical",
					action: {
						// TODO: Add licenses view
					}
				)
			}
		}
	}

	// MARK: - Actions

	private func openURL(_ urlString: String) {
		guard let url = URL(string: urlString) else { return }
		UIApplication.shared.open(url)
	}
}

// MARK: - Supporting Views

struct InfoRowView: View {
	let title: String
	let value: String

	var body: some View {
		HStack {
			Text(title)
				.font(.subheadline)
				.foregroundColor(.secondary)

			Spacer()

			Text(value)
				.font(.subheadline)
				.fontWeight(.medium)
		}
	}
}

struct LinkRowView: View {
	let title: String
	let subtitle: String?
	let systemImage: String
	let action: () -> Void

	init(title: String, subtitle: String? = nil, systemImage: String, action: @escaping () -> Void)
	{
		self.title = title
		self.subtitle = subtitle
		self.systemImage = systemImage
		self.action = action
	}

	var body: some View {
		Button(action: action) {
			HStack(spacing: 12) {
				Image(systemName: systemImage)
					.foregroundColor(.accentColor)
					.frame(width: 24)

				VStack(alignment: .leading, spacing: 2) {
					Text(title)
						.font(.subheadline)
						.fontWeight(.medium)
						.foregroundColor(.primary)

					if let subtitle = subtitle {
						Text(subtitle)
							.font(.caption)
							.foregroundColor(.secondary)
					}
				}

				Spacer()

				Image(systemName: "chevron.right")
					.font(.caption)
					.foregroundColor(.secondary)
			}
			.padding(.vertical, 8)
		}
		.buttonStyle(.plain)
	}
}

// MARK: - Preview

#if DEBUG
	struct AboutView_Previews: PreviewProvider {
		static var previews: some View {
			NavigationView {
				AboutView()
					.environmentObject(AppState())
			}
		}
	}
#endif
