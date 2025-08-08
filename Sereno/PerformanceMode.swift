//
//  PerformanceMode.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation

/// Represents different performance modes for AI model usage
enum PerformanceMode: String, CaseIterable, Codable {
    case lowPower = "Low Power"
    case balanced = "Balanced"
    case maxPower = "Max Power"
    
    /// Icon for the performance mode
    var icon: String {
        switch self {
        case .lowPower:
            return "battery.25"
        case .balanced:
            return "battery.50"
        case .maxPower:
            return "bolt.fill"
        }
    }
    
    /// Description of the performance mode
    var description: String {
        switch self {
        case .lowPower:
            return "Minimal model usage, optimized for battery life"
        case .balanced:
            return "Moderate performance, good balance of speed and efficiency"
        case .maxPower:
            return "Full model performance, higher CPU/GPU/NPU usage"
        }
    }
    
    /// Maximum memory usage for this performance mode (in MB)
    var maxMemoryUsage: Int {
        switch self {
        case .lowPower:
            return 512 // 512MB
        case .balanced:
            return 2048 // 2GB
        case .maxPower:
            return 8192 // 8GB
        }
    }
    
    /// Maximum concurrent operations for this performance mode
    var maxConcurrentOperations: Int {
        switch self {
        case .lowPower:
            return 1
        case .balanced:
            return 2
        case .maxPower:
            return 4
        }
    }
    
    /// Whether to use GPU acceleration for this mode
    var useGPUAcceleration: Bool {
        switch self {
        case .lowPower:
            return false
        case .balanced:
            return true
        case .maxPower:
            return true
        }
    }
    
    /// Whether to use Neural Engine for this mode
    var useNeuralEngine: Bool {
        switch self {
        case .lowPower:
            return false
        case .balanced:
            return true
        case .maxPower:
            return true
        }
    }
    
    /// Model quantization level for this mode
    var quantizationLevel: ModelQuantization {
        switch self {
        case .lowPower:
            return .int8
        case .balanced:
            return .int16
        case .maxPower:
            return .float32
        }
    }
    
    /// Context window size for this mode
    var contextWindowSize: Int {
        switch self {
        case .lowPower:
            return 1024 // 1K tokens
        case .balanced:
            return 4096 // 4K tokens
        case .maxPower:
            return 8192 // 8K tokens
        }
    }
    
    /// Estimated power consumption for this mode
    var estimatedPowerConsumption: PowerConsumption {
        switch self {
        case .lowPower:
            return .low
        case .balanced:
            return .medium
        case .maxPower:
            return .high
        }
    }
}

/// Represents model quantization levels
enum ModelQuantization: String, CaseIterable, Codable {
    case int8 = "INT8"
    case int16 = "INT16"
    case float32 = "FP32"
    
    var description: String {
        switch self {
        case .int8:
            return "8-bit quantization (smallest, fastest, lowest quality)"
        case .int16:
            return "16-bit quantization (balanced size and quality)"
        case .float32:
            return "32-bit float (largest, slowest, highest quality)"
        }
    }
}

/// Represents power consumption levels
enum PowerConsumption: String, CaseIterable, Codable {
    case low = "Low"
    case medium = "Medium"
    case high = "High"
    
    var icon: String {
        switch self {
        case .low:
            return "battery.25"
        case .medium:
            return "battery.50"
        case .high:
            return "bolt.fill"
        }
    }
    
    var color: String {
        switch self {
        case .low:
            return "green"
        case .medium:
            return "orange"
        case .high:
            return "red"
        }
    }
}

/// Configuration for AI model based on performance mode
struct ModelConfiguration {
    let performanceMode: PerformanceMode
    let maxMemoryUsage: Int
    let maxConcurrentOperations: Int
    let useGPUAcceleration: Bool
    let useNeuralEngine: Bool
    let quantizationLevel: ModelQuantization
    let contextWindowSize: Int
    let estimatedPowerConsumption: PowerConsumption
    
    init(performanceMode: PerformanceMode) {
        self.performanceMode = performanceMode
        self.maxMemoryUsage = performanceMode.maxMemoryUsage
        self.maxConcurrentOperations = performanceMode.maxConcurrentOperations
        self.useGPUAcceleration = performanceMode.useGPUAcceleration
        self.useNeuralEngine = performanceMode.useNeuralEngine
        self.quantizationLevel = performanceMode.quantizationLevel
        self.contextWindowSize = performanceMode.contextWindowSize
        self.estimatedPowerConsumption = performanceMode.estimatedPowerConsumption
    }
    
    /// Gets a human-readable description of the configuration
    var description: String {
        return """
        Performance Mode: \(performanceMode.rawValue)
        Memory Usage: \(maxMemoryUsage)MB
        Concurrent Operations: \(maxConcurrentOperations)
        GPU Acceleration: \(useGPUAcceleration ? "Enabled" : "Disabled")
        Neural Engine: \(useNeuralEngine ? "Enabled" : "Disabled")
        Quantization: \(quantizationLevel.rawValue)
        Context Window: \(contextWindowSize) tokens
        Power Consumption: \(estimatedPowerConsumption.rawValue)
        """
    }
} 