//
//  InstanceIndicator.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import UIKit

struct InstanceIndicator: View {
    let instanceName: String
    let instanceImage: String?
    
    @State private var mainColor: Color = .accentColor

    var foregroundColor: Color {
        .primary.mix(with: mainColor, by: 0.3)
    }
    
    var backgroundColor: Color {
        Color(uiColor: UIColor.systemBackground).mix(with: mainColor, by: 0.2)
    }

    init(instanceName: String, instanceImage: String?) {
        self.instanceName = instanceName
        self.instanceImage = instanceImage
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
        .task(id: instanceImage) {
            await extractColor()
        }
    }
    
    @MainActor
    private func extractColor() async {
        guard let urlString = instanceImage, let url = URL(string: urlString) else {
            mainColor = .accentColor
            return
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data), let average = uiImage.averageColor {
                mainColor = Color(uiColor: average)
            } else {
                mainColor = .accentColor
            }
        } catch {
            mainColor = .accentColor
        }
    }
}

#Preview {
    InstanceIndicator(instanceName: "example.com", instanceImage: nil)
    InstanceIndicator(instanceName: "example.com", instanceImage: "https://peertube.wtf/lazy-static/avatars/c8d8d77d-6761-4fcc-a83c-32dfea8c7777.png")
}

import CoreImage

extension UIImage {
    var averageColor: UIColor? {
        guard let inputImage = CIImage(image: self) else { return nil }
        let extentVector = CIVector(x: inputImage.extent.origin.x, y: inputImage.extent.origin.y, z: inputImage.extent.size.width, w: inputImage.extent.size.height)
        
        guard let filter = CIFilter(name: "CIAreaAverage", parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }
        
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull as Any])
        context.render(outputImage, toBitmap: &bitmap, rowBytes: 4, bounds: CGRect(x: 0, y: 0, width: 1, height: 1), format: .RGBA8, colorSpace: nil)
        
        return UIColor(red: CGFloat(bitmap[0]) / 255.0, green: CGFloat(bitmap[1]) / 255.0, blue: CGFloat(bitmap[2]) / 255.0, alpha: CGFloat(bitmap[3]) / 255.0)
    }
}
