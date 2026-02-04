// MARK: - BoundaryUseCases.swift
// Boundary Guardian
// Use Cases for boundary operations

import Foundation

// MARK: - Fetch Boundaries Use Case
struct FetchBoundariesUseCase {
    private let repository: BoundaryRepositoryProtocol
    
    init(repository: BoundaryRepositoryProtocol = BoundaryRepository()) {
        self.repository = repository
    }
    
    func execute() -> [BoundaryEntity] {
        switch repository.fetchAll() {
        case .success(let boundaries):
            return boundaries
        case .failure:
            return []
        }
    }
    
    func executeActive() -> [BoundaryEntity] {
        switch repository.fetchActive() {
        case .success(let boundaries):
            return boundaries
        case .failure:
            return []
        }
    }
}

// MARK: - Create Boundary Use Case
struct CreateBoundaryUseCase {
    private let repository: BoundaryRepositoryProtocol
    
    init(repository: BoundaryRepositoryProtocol = BoundaryRepository()) {
        self.repository = repository
    }
    
    func execute(
        title: String,
        consequence: String?,
        importance: Int16,
        category: CategoryEntity?
    ) -> BoundaryEntity {
        repository.create(
            title: title,
            consequence: consequence,
            importance: importance,
            category: category
        )
    }
}

// MARK: - Update Boundary Use Case
struct UpdateBoundaryUseCase {
    private let repository: BoundaryRepositoryProtocol
    
    init(repository: BoundaryRepositoryProtocol = BoundaryRepository()) {
        self.repository = repository
    }
    
    func execute(_ boundary: BoundaryEntity) -> Result<Void, AppError> {
        repository.update(boundary)
    }
}

// MARK: - Delete Boundary Use Case
struct DeleteBoundaryUseCase {
    private let repository: BoundaryRepositoryProtocol
    
    init(repository: BoundaryRepositoryProtocol = BoundaryRepository()) {
        self.repository = repository
    }
    
    func execute(_ boundary: BoundaryEntity) -> Result<Void, AppError> {
        repository.delete(boundary)
    }
}

// MARK: - Log Compliance Use Case
struct LogComplianceUseCase {
    private let complianceRepository: ComplianceRepositoryProtocol
    
    init(complianceRepository: ComplianceRepositoryProtocol = ComplianceRepository()) {
        self.complianceRepository = complianceRepository
    }
    
    @discardableResult
    func execute(
        boundary: BoundaryEntity,
        isKept: Bool,
        notes: String? = nil
    ) -> ComplianceEventEntity {
        complianceRepository.logCompliance(
            boundary: boundary,
            isKept: isKept,
            notes: notes
        )
    }
}

// MARK: - Get Statistics Use Case
struct GetStatisticsUseCase {
    private let boundaryRepository: BoundaryRepository
    private let complianceRepository: ComplianceRepository
    
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        complianceRepository: ComplianceRepository = ComplianceRepository()
    ) {
        self.boundaryRepository = boundaryRepository
        self.complianceRepository = complianceRepository
    }
    
    func executeBoundaryStatistics() -> BoundaryStatistics {
        boundaryRepository.getStatistics()
    }
    
    func executeComplianceStatistics(for period: StatisticsPeriod) -> ComplianceStatistics {
        complianceRepository.getStatistics(for: period)
    }
}

// MARK: - Calculate Streak Use Case
struct CalculateStreakUseCase {
    private let complianceRepository: ComplianceRepositoryProtocol
    
    init(complianceRepository: ComplianceRepositoryProtocol = ComplianceRepository()) {
        self.complianceRepository = complianceRepository
    }
    
    func execute(for boundary: BoundaryEntity) -> Int {
        let events = complianceRepository.fetchForBoundary(boundary)
        var streak = 0
        var currentDate = Date().startOfDay
        
        for event in events.sorted(by: { $0.date > $1.date }) {
            let eventDate = event.date.startOfDay
            
            if eventDate == currentDate && event.isKept {
                streak += 1
                currentDate = currentDate.adding(days: -1)
            } else if eventDate < currentDate || !event.isKept {
                break
            }
        }
        
        return streak
    }
}
