//
//  InstanceIndicator.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI

struct InstanceIndicator: View {
    let instanceName: String
    let instanceImage: String?
    
    
    // IDEA: Get dominant color from image
    let mainColor: Color = Color.accentColor
    let foregroundColor: Color
    let backgroundColor: Color

    init(instanceName: String, instanceImage: String?) {
        self.instanceName = instanceName
        self.instanceImage = instanceImage
        
        let systemBackground: Color = Color(uiColor: UIColor.systemBackground)
        foregroundColor = .primary.mix(with: mainColor, by: 0.3)
        backgroundColor = systemBackground.mix(with: mainColor, by: 0.2)
    }
    
    var body: some View {
        HStack (spacing: 2) {
            if let url = URL(string: instanceImage ?? "") {
                AsyncImage(url: url) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                        .frame(width: 12, height: 12)
                }
                    .frame(width: 12, height: 12)
                    .foregroundStyle(.black)
                    .frame(width: 20, height: 20)
                    .background(backgroundColor)
                    .clipShape(.rect(cornerRadius: 8))
                    .rotationEffect(Angle(degrees: -3))
            } else {
                Image(systemName: "laser.burst")
                    .resizable()
                    .frame(width: 12, height: 12)
                    .foregroundStyle(foregroundColor)
                    .frame(width: 20, height: 20)
                    .background(backgroundColor)
                    .clipShape(.rect(cornerRadius: 8))
                    .rotationEffect(Angle(degrees: -3))
            }
            
            Text(instanceName)
                .font(.caption2)
                .padding(.horizontal, 6)
                .foregroundStyle(foregroundColor)
                .background(backgroundColor)
                .clipShape(.rect(cornerRadius: 4))
        }
    }
}

#Preview {
    InstanceIndicator(instanceName: "example.com", instanceImage: nil)
    InstanceIndicator(instanceName: "example.com", instanceImage: "https://peertube.wtf/lazy-static/avatars/c8d8d77d-6761-4fcc-a83c-32dfea8c7777.png")
}
