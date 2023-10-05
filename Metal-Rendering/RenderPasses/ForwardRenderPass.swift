//
//  ForwardRenderPass.swift
//  Metal-Rendering
//
//  Created by JINSEN WU on 10/4/23.
//

import MetalKit

struct ForwardRenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    
    init(view: MTKView) {
        pipelineState = PipelineStates.createForwardPSO(colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(descriptor: descriptor)
    }
    
    mutating func resize(view: MTKView, size: CGSize) {}
    
    func draw(commandBuffer: MTLCommandBuffer, scene: GameScene, uniforms: Uniforms, params: Params) {
        guard let descriptor = descriptor,
              let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {return}
        
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(&lights, length: MemoryLayout<Light>.stride * lights.count, index: LightBuffer.index)
        
        for model in scene.models {
            model.render(encoder: renderEncoder, uniforms: uniforms, params: params)
        }
        renderEncoder.endEncoding()
    }
}
