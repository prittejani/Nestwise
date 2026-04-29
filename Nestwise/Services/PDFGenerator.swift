// PDFGenerator.swift
// Nestwise – AI Parenting Guide

import Foundation
import UIKit
import PDFKit

final class PDFGenerator {
    
    static func generateMilestoneReport(child: ChildProfile, logs: [MilestoneLog], totalMilestones: Int) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "Nestwise App",
            kCGPDFContextAuthor: "Nestwise",
            kCGPDFContextTitle: "\(child.name)'s Milestone Report"
        ]
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        // 8.5 x 11 inches (standard US Letter)
        let pageWidth = 8.5 * 72.0
        let pageHeight = 11.0 * 72.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            // --- Title ---
            let titleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 28, weight: .bold),
                .foregroundColor: UIColor.systemIndigo
            ]
            let title = "\(child.name)'s Milestone Report"
            let titleSize = title.size(withAttributes: titleAttributes)
            let titleRect = CGRect(x: 36, y: 36, width: titleSize.width, height: titleSize.height)
            title.draw(in: titleRect, withAttributes: titleAttributes)
            
            // --- Subtitle / Progress ---
            let progress = totalMilestones > 0 ? (Double(logs.count) / Double(totalMilestones)) * 100 : 0
            let subtitleAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14, weight: .medium),
                .foregroundColor: UIColor.darkGray
            ]
            let subtitle = "Age: \(child.ageDisplayString)   |   Progress: \(Int(progress))% (\(logs.count)/\(totalMilestones))"
            let subtitleRect = CGRect(x: 36, y: titleRect.maxY + 12, width: pageWidth - 72, height: 20)
            subtitle.draw(in: subtitleRect, withAttributes: subtitleAttributes)
            
            // Line separator
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.setLineWidth(1)
            context.cgContext.move(to: CGPoint(x: 36, y: subtitleRect.maxY + 16))
            context.cgContext.addLine(to: CGPoint(x: pageWidth - 36, y: subtitleRect.maxY + 16))
            context.cgContext.strokePath()
            
            // --- List of Achieved Milestones ---
            var currentY: CGFloat = subtitleRect.maxY + 36
            
            let categoryAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .semibold),
                .foregroundColor: UIColor.black
            ]
            
            let itemAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 12, weight: .regular),
                .foregroundColor: UIColor.black
            ]
            
            let dateAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 11, weight: .regular),
                .foregroundColor: UIColor.gray
            ]
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            // Group and map logs to actual milestones
            var milestonesByCategory: [Milestone.MilestoneCategory: [(Milestone, Date)]] = [:]
            
            let achievedMilestones = logs.compactMap { log -> (Milestone, Date)? in
                // Search across all catalogs
                for group in AgeGroup.allCases {
                    if let m = MilestoneCatalog.milestones(for: group).first(where: { $0.id == log.milestoneID }) {
                        return (m, log.achievedAt)
                    }
                }
                return nil
            }
            
            for item in achievedMilestones {
                milestonesByCategory[item.0.category, default: []].append(item)
            }
            
            for category in Milestone.MilestoneCategory.allCases {
                guard let categoryItems = milestonesByCategory[category], !categoryItems.isEmpty else { continue }
                
                // Sort by date descending
                let sortedItems = categoryItems.sorted { $0.1 > $1.1 }
                
                // Check page bounds before category title
                if currentY > pageHeight - 100 {
                    drawFooter(context: context.cgContext, pageRect: pageRect)
                    context.beginPage()
                    currentY = 36
                }
                
                category.rawValue.draw(at: CGPoint(x: 36, y: currentY), withAttributes: categoryAttributes)
                currentY += 24
                
                for (milestone, date) in sortedItems {
                    // Check page bounds for item
                    if currentY > pageHeight - 50 {
                        drawFooter(context: context.cgContext, pageRect: pageRect)
                        context.beginPage()
                        currentY = 36
                    }
                    
                    let text = "• \(milestone.title)"
                    text.draw(at: CGPoint(x: 48, y: currentY), withAttributes: itemAttributes)
                    
                    let dateText = dateFormatter.string(from: date)
                    let dateSize = dateText.size(withAttributes: dateAttributes)
                    dateText.draw(at: CGPoint(x: pageWidth - 36 - dateSize.width, y: currentY), withAttributes: dateAttributes)
                    
                    currentY += 20
                }
                
                currentY += 16
            }
            
            // Footer on last page
            drawFooter(context: context.cgContext, pageRect: pageRect)
        }
        
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(child.name)_Milestones.pdf")
        do {
            try data.write(to: tempURL)
            return tempURL
        } catch {
            print("Failed to save PDF: \(error.localizedDescription)")
            return nil
        }
    }
    
    private static func drawFooter(context: CGContext, pageRect: CGRect) {
        let footerAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .regular),
            .foregroundColor: UIColor.gray
        ]
        let footerText = "Generated by Nestwise – Your AI Parenting Guide"
        let footerSize = footerText.size(withAttributes: footerAttributes)
        footerText.draw(at: CGPoint(x: (pageRect.width - footerSize.width) / 2, y: pageRect.height - 36), withAttributes: footerAttributes)
    }
}
