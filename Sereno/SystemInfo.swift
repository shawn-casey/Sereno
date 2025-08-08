//
//  SystemInfo.swift
//  Sereno
//
//  Created by Shawn Casey on 8/6/25.
//

import Foundation
import Darwin

/// System information and hardware detection for automatic model optimization
struct SystemInfo {
    
    /// Represents the system's hardware capabilities
    struct HardwareCapabilities {
        let chipModel: String
        let totalRAM: Int64 // in bytes
        let availableRAM: Int64 // in bytes
        let isOnBattery: Bool
        let batteryLevel: Double? // 0.0 to 1.0, nil if not available
        let processorCount: Int
        let isLowPowerMode: Bool
    }
    
    /// Detects the current system's hardware capabilities
    /// - Returns: HardwareCapabilities object with system information
    static func getHardwareCapabilities() -> HardwareCapabilities {
        let chipModel = getChipModel()
        let totalRAM = getTotalRAM()
        let availableRAM = getAvailableRAM()
        let isOnBattery = isOnBattery()
        let batteryLevel = getBatteryLevel()
        let processorCount = ProcessInfo.processInfo.processorCount
        let isLowPowerMode = ProcessInfo.processInfo.isLowPowerModeEnabled
        
        return HardwareCapabilities(
            chipModel: chipModel,
            totalRAM: totalRAM,
            availableRAM: availableRAM,
            isOnBattery: isOnBattery,
            batteryLevel: batteryLevel,
            processorCount: processorCount,
            isLowPowerMode: isLowPowerMode
        )
    }
    
    /// Gets the chip model (M1, M2, M3, etc.)
    /// - Returns: String representation of the chip model
    private static func getChipModel() -> String {
        var size = 0
        sysctlbyname("machdep.cpu.brand_string", nil, &size, nil, 0)
        
        var machine = [CChar](repeating: 0, count: size)
        sysctlbyname("machdep.cpu.brand_string", &machine, &size, nil, 0)
        
        let chipString = String(cString: machine)
        
        // Extract chip model from the string
        if chipString.contains("Apple M1") {
            return "Apple M1"
        } else if chipString.contains("Apple M2") {
            return "Apple M2"
        } else if chipString.contains("Apple M3") {
            return "Apple M3"
        } else if chipString.contains("Apple M4") {
            return "Apple M4"
        } else if chipString.contains("Intel") {
            return "Intel"
        } else {
            return "Unknown"
        }
    }
    
    /// Gets total RAM in bytes
    /// - Returns: Total RAM in bytes
    private static func getTotalRAM() -> Int64 {
        return Int64(ProcessInfo.processInfo.physicalMemory)
    }
    
    /// Gets available RAM in bytes
    /// - Returns: Available RAM in bytes
    private static func getAvailableRAM() -> Int64 {
        var pagesize: vm_size_t = 0
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)
        
        host_page_size(mach_host_self(), &pagesize)
        
        _ = withUnsafeMutablePointer(to: &stats) { statsPointer in
            statsPointer.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { integerPointer in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, integerPointer, &count)
            }
        }
        
        let freePages = Int64(stats.free_count)
        return freePages * Int64(pagesize)
    }
    
    /// Checks if the system is running on battery power
    /// - Returns: True if on battery, false if plugged in
    private static func isOnBattery() -> Bool {
        // For now, return false to avoid IOKit issues in previews
        // TODO: Implement proper battery detection when needed
        return false
    }
    
    /// Gets the current battery level
    /// - Returns: Battery level as a Double (0.0 to 1.0), nil if not available
    private static func getBatteryLevel() -> Double? {
        // For now, return nil to avoid IOKit issues in previews
        // TODO: Implement proper battery level detection when needed
        return nil
    }
    
    /// Determines the recommended performance mode based on hardware capabilities
    /// - Parameter capabilities: The system's hardware capabilities
    /// - Returns: Recommended PerformanceMode
    static func getRecommendedPerformanceMode(for capabilities: HardwareCapabilities) -> PerformanceMode {
        // Check for low power conditions
        if capabilities.isLowPowerMode {
            return .lowPower // System low power mode enabled
        }
        
        // Check for high-end hardware
        let isHighEndChip = capabilities.chipModel.contains("M3 Pro") || 
                           capabilities.chipModel.contains("M3 Max") ||
                           capabilities.chipModel.contains("M2 Pro") ||
                           capabilities.chipModel.contains("M2 Max")
        
        let hasLotsOfRAM = capabilities.totalRAM >= 16 * 1024 * 1024 * 1024 // 16GB or more
        let hasGoodAvailableRAM = capabilities.availableRAM >= 8 * 1024 * 1024 * 1024 // 8GB available
        
        if isHighEndChip && hasLotsOfRAM && hasGoodAvailableRAM {
            return .maxPower // High-end hardware
        }
        
        // Default to balanced for most scenarios
        return .balanced
    }
    
    /// Gets a human-readable description of the system capabilities
    /// - Parameter capabilities: The system's hardware capabilities
    /// - Returns: Formatted string describing the system
    static func getSystemDescription(for capabilities: HardwareCapabilities) -> String {
        let ramGB = capabilities.totalRAM / (1024 * 1024 * 1024)
        let availableGB = capabilities.availableRAM / (1024 * 1024 * 1024)
        
        var description = "\(capabilities.chipModel) • \(ramGB)GB RAM (\(availableGB)GB available) • \(capabilities.processorCount) cores"
        
        // Note: Battery detection is disabled for preview compatibility
        description += " • Desktop Mode"
        
        if capabilities.isLowPowerMode {
            description += " • Low Power Mode"
        }
        
        return description
    }
} 