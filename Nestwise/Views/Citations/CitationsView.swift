//
//  CitationsView.swift
//  Nestwise
//
//  Created by Prit  on 17/04/26.
//

import SwiftUI

struct CitationsView: View {

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                headerCard
                ForEach(CitationSource.all) { source in
                    CitationCard(source: source)
                }
                disclaimerCard
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 24)
        }
        .background(NWColors.background)
        .navigationTitle("Medical Sources")
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Header
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                Image(systemName: "cross.case.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.red)
                Text("Evidence-based guidance")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
            }
            Text("All parenting advice in NestWise is based on guidelines from the world's leading paediatric and health organisations. Tap any source to visit the original.")
                .font(.system(size: 13))
                .foregroundStyle(NWColors.secondaryText)
                .lineSpacing(3)
        }
        .padding(16)
        .background(Color.red.opacity(0.06), in: RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Disclaimer
    private var disclaimerCard: some View {
        VStack(spacing: 8) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 20))
                .foregroundStyle(.orange)
            Text("Not a substitute for medical advice")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(NWColors.primaryText)
            Text("NestWise provides general parenting information only. Always consult a qualified paediatrician or healthcare provider for medical concerns about your child.")
                .font(.system(size: 13))
                .foregroundStyle(NWColors.secondaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
        .padding(20)
        .background(Color.orange.opacity(0.08), in: RoundedRectangle(cornerRadius: 14))
        .padding(.top, 8)
    }
}

// MARK: - Citation Card
struct CitationCard: View {
    let source: CitationSource

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(source.color.opacity(0.12))
                        .frame(width: 36, height: 36)
                    Image(systemName: source.icon)
                        .font(.system(size: 15))
                        .foregroundStyle(source.color)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(source.shortName)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(NWColors.primaryText)
                    Text(source.region)
                        .font(.system(size: 11))
                        .foregroundStyle(NWColors.tertiaryText)
                }
                Spacer()
                Image(systemName: "arrow.up.right.square")
                    .font(.system(size: 14))
                    .foregroundStyle(NWColors.accent)
            }

            Text(source.fullName)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(NWColors.secondaryText)

            Text(source.usedFor)
                .font(.system(size: 12))
                .foregroundStyle(NWColors.tertiaryText)
                .lineSpacing(2)

            Button {
                if let url = URL(string: source.url) {
                    UIApplication.shared.open(url)
                }
            } label: {
                Text(source.url)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundStyle(NWColors.accent)
                    .lineLimit(1)
                    .truncationMode(.middle)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 14))
    }
}

// MARK: - Citation Source Model
struct CitationSource: Identifiable {
    let id = UUID()
    let shortName: String
    let fullName: String
    let region: String
    let usedFor: String
    let url: String
    let icon: String
    let color: Color

    static let all: [CitationSource] = [
        CitationSource(
            shortName: "AAP",
            fullName: "American Academy of Pediatrics",
            region: "United States",
            usedFor: "Sleep guidelines, screen time recommendations, feeding schedules, developmental milestones, vaccine schedules",
            url: "https://www.aap.org",
            icon: "staroflife.fill",
            color: .blue
        ),
        CitationSource(
            shortName: "WHO",
            fullName: "World Health Organization",
            region: "Global",
            usedFor: "Growth charts, breastfeeding guidance, global milestone standards, immunisation recommendations",
            url: "https://www.who.int/health-topics/child-health",
            icon: "globe",
            color: .teal
        ),
        CitationSource(
            shortName: "NHS",
            fullName: "National Health Service",
            region: "United Kingdom",
            usedFor: "UK-specific child health guidance, weaning advice, developmental checks, sleep safety",
            url: "https://www.nhs.uk/conditions/baby",
            icon: "cross.fill",
            color: .red
        ),
        CitationSource(
            shortName: "CDC",
            fullName: "Centers for Disease Control and Prevention",
            region: "United States",
            usedFor: "Developmental milestone checklists (Learn the Signs. Act Early.), immunisation schedules",
            url: "https://www.cdc.gov/ncbddd/actearly/milestones",
            icon: "checklist",
            color: .orange
        ),
        CitationSource(
            shortName: "UNICEF",
            fullName: "United Nations Children's Fund",
            region: "Global",
            usedFor: "Early childhood development frameworks, nutrition guidance, child rights and wellbeing",
            url: "https://www.unicef.org/early-childhood-development",
            icon: "person.2.fill",
            color: .purple
        ),
        CitationSource(
            shortName: "NIH",
            fullName: "National Institutes of Health",
            region: "United States",
            usedFor: "Sleep science, infant nutrition research, mental health guidance for parents",
            url: "https://www.nichd.nih.gov/health/topics",
            icon: "book.fill",
            color: .green
        ),
        CitationSource(
            shortName: "RCPCH",
            fullName: "Royal College of Paediatrics and Child Health",
            region: "United Kingdom",
            usedFor: "UK paediatric clinical guidelines, child development standards, health checks",
            url: "https://www.rcpch.ac.uk",
            icon: "stethoscope",
            color: .indigo
        ),
    ]
}
