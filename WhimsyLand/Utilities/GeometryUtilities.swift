//
//  GeometryUtilities.swift
//  WhimsyLand
//
//  Created by changhyen yun on 7/9/25.
//
/*
확장 및 유틸리티
*/


import Foundation
import RealityKit

//  X, Y, Z축 방향 벡터 + 위치 벡터
extension simd_float4x4 {
    init(translation vector: SIMD3<Float>) {
        self.init(SIMD4<Float>(1, 0, 0, 0),
                  SIMD4<Float>(0, 1, 0, 0),
                  SIMD4<Float>(0, 0, 1, 0),
                  SIMD4<Float>(vector.x, vector.y, vector.z, 1))
    }
    
    var translation: SIMD3<Float> {
        get {
            columns.3.xyz
        }
        set {
            self.columns.3 = [newValue.x, newValue.y, newValue.z, 1]
        }
    }
    
    var rotation: simd_quatf {
        simd_quatf(rotationMatrix)
    }
    
    var xAxis: SIMD3<Float> { columns.0.xyz }
    
    var yAxis: SIMD3<Float> { columns.1.xyz }
    
    var zAxis: SIMD3<Float> { columns.2.xyz }
    
    var rotationMatrix: simd_float3x3 {
        matrix_float3x3(xAxis,
                        yAxis,
                        zAxis)
    }
    
    /// 4x4 matrix. 중력 정렬  얻기
    var gravityAligned: simd_float4x4 {
        // Z축을 수평면에 투영하고 길이 1로 정규화
        let projectedZAxis: SIMD3<Float> = [zAxis.x, 0.0, zAxis.z]
        let normalizedZAxis = normalize(projectedZAxis)
        
        // 하드코딩 y-axis 1 point 위로
        let gravityAlignedYAxis: SIMD3<Float> = [0, 1, 0]
        
        let resultingXAxis = normalize(cross(gravityAlignedYAxis, normalizedZAxis))
        
        return simd_matrix(
            SIMD4(resultingXAxis.x, resultingXAxis.y, resultingXAxis.z, 0),
            SIMD4(gravityAlignedYAxis.x, gravityAlignedYAxis.y, gravityAlignedYAxis.z, 0),
            SIMD4(normalizedZAxis.x, normalizedZAxis.y, normalizedZAxis.z, 0),
            columns.3
        )
    }
}

// x,y,z,w(동차 좌표 1 위치, 0 방향)
extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}
