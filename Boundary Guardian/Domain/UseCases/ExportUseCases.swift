// MARK: - ExportUseCases.swift
// Boundary Guardian
// Use Cases for data export

import Foundation
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

// MARK: - Export PDF Use Case
struct ExportPDFUseCase {
    private let boundaryRepository: BoundaryRepository
    private let complianceRepository: ComplianceRepository
    private let reflectionRepository: ReflectionRepository
    
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        complianceRepository: ComplianceRepository = ComplianceRepository(),
        reflectionRepository: ReflectionRepository = ReflectionRepository()
    ) {
        self.boundaryRepository = boundaryRepository
        self.complianceRepository = complianceRepository
        self.reflectionRepository = reflectionRepository
    }
    
    /// Generates PDF report
    func execute() -> Data? {
        let boundaries: [BoundaryEntity] = boundaryRepository.fetchAll()
        let statistics = boundaryRepository.getStatistics()
        let reflections = reflectionRepository.fetchRecent(limit: 12)
        
        // Create HTML for PDF
        let html = generateHTML(
            boundaries: boundaries,
            statistics: statistics,
            reflections: reflections
        )
        
        return generatePDF(from: html)
    }
    
    private func generateHTML(
        boundaries: [BoundaryEntity],
        statistics: BoundaryStatistics,
        reflections: [ReflectionEntity]
    ) -> String {
        let year = Calendar.current.component(.year, from: Date())
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <style>
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: linear-gradient(135deg, #0A192F 0%, #050D1A 100%);
                    color: #F8F9FA;
                    padding: 40px;
                    margin: 0;
                }
                .header {
                    text-align: center;
                    margin-bottom: 40px;
                }
                .title {
                    font-size: 32px;
                    font-weight: bold;
                    color: #D4AF37;
                    margin-bottom: 8px;
                }
                .subtitle {
                    font-size: 18px;
                    color: #C0C0C0;
                }
                .shield-icon {
                    font-size: 60px;
                    margin-bottom: 20px;
                }
                .stats-container {
                    display: flex;
                    justify-content: space-around;
                    margin: 40px 0;
                    flex-wrap: wrap;
                }
                .stat-card {
                    background: rgba(255,255,255,0.1);
                    border-radius: 16px;
                    padding: 24px;
                    text-align: center;
                    min-width: 150px;
                    margin: 10px;
                }
                .stat-number {
                    font-size: 48px;
                    font-weight: bold;
                    color: #D4AF37;
                }
                .stat-label {
                    font-size: 14px;
                    color: #C0C0C0;
                    margin-top: 8px;
                }
                .section {
                    margin: 40px 0;
                }
                .section-title {
                    font-size: 24px;
                    font-weight: 600;
                    color: #D4AF37;
                    border-bottom: 2px solid #D4AF37;
                    padding-bottom: 8px;
                    margin-bottom: 20px;
                }
                .boundary-card {
                    background: rgba(255,255,255,0.05);
                    border-radius: 12px;
                    padding: 16px;
                    margin-bottom: 12px;
                    border-left: 4px solid #50C878;
                }
                .boundary-title {
                    font-size: 18px;
                    font-weight: 600;
                    margin-bottom: 8px;
                }
                .boundary-meta {
                    font-size: 14px;
                    color: #C0C0C0;
                }
                .footer {
                    text-align: center;
                    margin-top: 60px;
                    padding-top: 20px;
                    border-top: 1px solid rgba(255,255,255,0.1);
                    color: #6C757D;
                }
            </style>
        </head>
        <body>
            <div class="header">
                <div class="shield-icon">🛡️</div>
                <div class="title">My Financial Boundaries</div>
                <div class="subtitle">\(year) Annual Report</div>
            </div>
            
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-number">\(statistics.strengthPercentage)%</div>
                    <div class="stat-label">Boundary Strength</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">\(statistics.activeBoundaries)</div>
                    <div class="stat-label">Active Boundaries</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">\(statistics.longestStreak)</div>
                    <div class="stat-label">Longest Streak</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">\(statistics.totalKeptEvents)</div>
                    <div class="stat-label">Times Protected</div>
                </div>
            </div>
            
            <div class="section">
                <div class="section-title">Your Boundaries</div>
                \(boundaries.map { boundary in
                    """
                    <div class="boundary-card">
                        <div class="boundary-title">\(boundary.title)</div>
                        <div class="boundary-meta">
                            Streak: \(boundary.currentStreak) days • 
                            Importance: \(String(repeating: "🛡️", count: Int(boundary.importance)))
                        </div>
                    </div>
                    """
                }.joined())
            </div>
            
            <div class="footer">
                <p>Generated by Boundary Guardian</p>
                <p>Protect your finances. Protect your future.</p>
            </div>
        </body>
        </html>
        """
    }
    
    private func generatePDF(from html: String) -> Data? {
        #if os(iOS)
        let printFormatter = UIMarkupTextPrintFormatter(markupText: html)
        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pageSize = CGSize(width: 595.2, height: 841.8) // A4 size
        let pageRect = CGRect(origin: .zero, size: pageSize)
        
        renderer.setValue(pageRect, forKey: "paperRect")
        renderer.setValue(pageRect, forKey: "printableRect")
        
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext()
        return pdfData as Data
        #else
        return nil
        #endif
    }
}

// MARK: - Export Share Card Use Case
struct ExportShareCardUseCase {
    private let boundaryRepository: BoundaryRepository
    
    init(boundaryRepository: BoundaryRepository = BoundaryRepository()) {
        self.boundaryRepository = boundaryRepository
    }
    
    /// Generates image for social sharing
    @MainActor
    func execute(for boundary: BoundaryEntity) -> Image? {
        // Create SwiftUI View for rendering
        let view = ShareCardView(boundary: boundary)
        
        // Render to Image
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        
        #if os(iOS)
        if let uiImage = renderer.uiImage {
            return Image(uiImage: uiImage)
        }
        #elseif os(macOS)
        if let nsImage = renderer.nsImage {
            return Image(nsImage: nsImage)
        }
        #endif
        
        return nil
    }
}

// MARK: - Share Card View
struct ShareCardView: View {
    let boundary: BoundaryEntity
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            HStack {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 40))
                    .foregroundStyle(AppColors.warmGold)
                
                Spacer()
            }
            
            // Content
            VStack(alignment: .leading, spacing: 12) {
                Text("I'm protecting my boundaries")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppColors.metallicSilver)
                
                Text(boundary.title)
                    .font(.system(size: 24, weight: .bold, design: .serif))
                    .foregroundStyle(AppColors.softWhite)
                    .lineLimit(3)
                
                HStack(spacing: 16) {
                    Label("\(boundary.currentStreak) days", systemImage: "flame.fill")
                        .foregroundStyle(AppColors.warmGold)
                    
                    Label("\(Int(boundary.complianceRate))%", systemImage: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(AppColors.protectiveEmerald)
                }
                .font(.system(size: 14, weight: .semibold))
            }
            
            Spacer()
            
            // Footer
            HStack {
                Text("Boundary Guardian")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppColors.mutedGray)
                
                Spacer()
                
                ForEach(0..<Int(boundary.importance), id: \.self) { _ in
                    Image(systemName: "shield.fill")
                        .font(.system(size: 12))
                        .foregroundStyle(AppColors.warmGold)
                }
            }
        }
        .padding(32)
        .frame(width: 400, height: 500)
        .background(AppColors.backgroundGradient)
    }
}

// MARK: - Backup Use Case
struct BackupUseCase {
    private let boundaryRepository: BoundaryRepository
    private let categoryRepository: CategoryRepository
    private let reflectionRepository: ReflectionRepository
    
    init(
        boundaryRepository: BoundaryRepository = BoundaryRepository(),
        categoryRepository: CategoryRepository = CategoryRepository(),
        reflectionRepository: ReflectionRepository = ReflectionRepository()
    ) {
        self.boundaryRepository = boundaryRepository
        self.categoryRepository = categoryRepository
        self.reflectionRepository = reflectionRepository
    }
    
    /// Creates JSON backup of all data
    func createBackup() -> Data? {
        let boundaries: [BoundaryEntity] = boundaryRepository.fetchAll()
        let categories: [CategoryEntity] = categoryRepository.fetchAll()
        let reflections: [ReflectionEntity] = reflectionRepository.fetchAll()
        
        let backup = BackupData(
            version: "1.0",
            createdAt: Date(),
            boundaries: boundaries.map { BoundaryBackup(from: $0) },
            categories: categories.map { CategoryBackup(from: $0) },
            reflections: reflections.map { ReflectionBackup(from: $0) }
        )
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        encoder.dateEncodingStrategy = .iso8601
        
        return try? encoder.encode(backup)
    }
}

// MARK: - Backup Models
struct BackupData: Codable {
    let version: String
    let createdAt: Date
    let boundaries: [BoundaryBackup]
    let categories: [CategoryBackup]
    let reflections: [ReflectionBackup]
}

struct BoundaryBackup: Codable {
    let id: UUID
    let title: String
    let consequenceText: String?
    let importance: Int16
    let createdAt: Date
    let isActive: Bool
    let currentStreak: Int32
    let longestStreak: Int32
    let categoryId: UUID?
    
    init(from entity: BoundaryEntity) {
        self.id = entity.id
        self.title = entity.title
        self.consequenceText = entity.consequenceText
        self.importance = entity.importance
        self.createdAt = entity.createdAt
        self.isActive = entity.isActive
        self.currentStreak = entity.currentStreak
        self.longestStreak = entity.longestStreak
        self.categoryId = entity.category?.id
    }
}

struct CategoryBackup: Codable {
    let id: UUID
    let name: String
    let icon: String
    let colorHex: String
    let createdAt: Date
    
    init(from entity: CategoryEntity) {
        self.id = entity.id
        self.name = entity.name
        self.icon = entity.icon
        self.colorHex = entity.colorHex
        self.createdAt = entity.createdAt
    }
}

struct ReflectionBackup: Codable {
    let id: UUID
    let weekStartDate: Date
    let strengths: String?
    let challenges: String?
    let intentions: String?
    let moodRating: Int16
    let createdAt: Date
    
    init(from entity: ReflectionEntity) {
        self.id = entity.id
        self.weekStartDate = entity.weekStartDate
        self.strengths = entity.strengths
        self.challenges = entity.challenges
        self.intentions = entity.intentions
        self.moodRating = entity.moodRating
        self.createdAt = entity.createdAt
    }
}
