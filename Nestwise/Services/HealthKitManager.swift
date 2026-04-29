// HealthKitManager.swift
// Nestwise – AI Parenting Guide

import Foundation
import HealthKit
import Combine

final class HealthKitManager: ObservableObject {
    static let shared = HealthKitManager()
    
    private let healthStore = HKHealthStore()
    
    @Published var lastNightSleepHours: Double? = nil
    
    private init() {}
    
    // MARK: - Authorization
    func requestAuthorization() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            return
        }
        
        let typesToRead: Set<HKObjectType> = [sleepType, stepCountType]
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { [weak self] success, error in
            if success {
                self?.fetchLastNightSleep()
            }
        }
    }
    
    // MARK: - Fetch Data
    func fetchLastNightSleep() {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return }
        
        // We look for sleep records that ended in the past 24 hours
        let past24Hours = Date().addingTimeInterval(-24 * 60 * 60)
        let predicate = HKQuery.predicateForSamples(withStart: past24Hours, end: Date(), options: .strictEndDate)
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 100, sortDescriptors: [sortDescriptor]) { [weak self] _, samples, error in
            
            guard let self = self, let sleepSamples = samples as? [HKCategorySample] else { return }
            
            // Filter for actual sleep time (not just "in bed")
            // Apple Watch tracks asleep, asleepCore, asleepDeep, asleepREM
            let sleepRecords = sleepSamples.filter {
                $0.value == HKCategoryValueSleepAnalysis.asleep.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepCore.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue ||
                $0.value == HKCategoryValueSleepAnalysis.asleepREM.rawValue
            }
            
            let totalSeconds = sleepRecords.reduce(0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
            let hours = totalSeconds / 3600.0
            
            DispatchQueue.main.async {
                self.lastNightSleepHours = hours > 0 ? hours : nil
            }
        }
        
        healthStore.execute(query)
    }
}
