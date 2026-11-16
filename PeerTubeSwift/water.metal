//
//  water.metal
//  PeerTubeSwift
//
//  Created by Eric Wätke on 16.11.26.
//

#include <metal_stdlib>
#include <SwiftUI/SwiftUI_Metal.h>
using namespace metal;

[[ stitchable ]] float2 wave(float2 pos, float time) {
  pos.y += sin(time * 5 + pos.y / 20) * 5;
  return pos;
}

[[ stitchable ]] half4 loupe(float2 pos, SwiftUI::Layer l, float2 size, float2 touch) {
  
}
