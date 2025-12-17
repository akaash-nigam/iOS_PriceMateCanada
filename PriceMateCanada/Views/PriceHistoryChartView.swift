//
//  PriceHistoryChartView.swift
//  PriceMateCanada
//
//  Enhanced price history visualization with Charts framework
//

import SwiftUI
import Charts

struct PriceHistory: Identifiable {
    let id = UUID()
    let date: Date
    let price: Double
    let store: String
}

struct EnhancedPriceHistoryChart: View {
    let product: Product

    // Generate mock price history data
    var priceHistory: [PriceHistory] {
        let calendar = Calendar.current
        var history: [PriceHistory] = []

        // Generate 30 days of price data
        for daysAgo in (0...30).reversed() {
            if let date = calendar.date(byAdding: .day, value: -daysAgo, to: Date()) {
                // Randomly select a store from product prices
                let randomStore = product.prices.randomElement()?.store.name ?? "Unknown"
                let basePrice = product.prices.first?.price ?? 4.99

                // Add some variation to prices
                let variation = Double.random(in: -1.0...1.0)
                let price = max(basePrice + variation, 0.99)

                history.append(PriceHistory(date: date, price: price, store: randomStore))
            }
        }

        return history
    }

    var averagePrice: Double {
        let total = priceHistory.reduce(0) { $0 + $1.price }
        return total / Double(priceHistory.count)
    }

    var lowestPrice: Double {
        priceHistory.map { $0.price }.min() ?? 0
    }

    var highestPrice: Double {
        priceHistory.map { $0.price }.max() ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Price History")
                    .font(.headline)
                Spacer()
                Text("Last 30 days")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // Chart
            Chart(priceHistory) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Price", entry.price)
                )
                .foregroundStyle(Color.red.gradient)
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", entry.date),
                    y: .value("Price", entry.price)
                )
                .foregroundStyle(
                    LinearGradient(
                        gradient: Gradient(colors: [Color.red.opacity(0.3), Color.red.opacity(0.05)]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let price = value.as(Double.self) {
                            Text("$\(price, specifier: "%.2f")")
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day, count: 7)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }

            // Statistics
            HStack(spacing: 20) {
                PriceStatCard(
                    title: "Lowest",
                    value: lowestPrice,
                    color: .green
                )

                PriceStatCard(
                    title: "Average",
                    value: averagePrice,
                    color: .blue
                )

                PriceStatCard(
                    title: "Highest",
                    value: highestPrice,
                    color: .orange
                )
            }

            // Price trend indicator
            HStack {
                Image(systemName: currentTrend().icon)
                    .foregroundColor(currentTrend().color)
                Text(currentTrend().message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(currentTrend().color.opacity(0.1))
            .cornerRadius(8)
        }
        .padding()
        .background(Color.gray.opacity(0.05))
        .cornerRadius(12)
    }

    private func currentTrend() -> (icon: String, message: String, color: Color) {
        guard priceHistory.count >= 7 else {
            return ("minus", "Not enough data to determine trend", .gray)
        }

        let recentPrices = Array(priceHistory.suffix(7))
        let olderPrices = Array(priceHistory.prefix(7))

        let recentAvg = recentPrices.reduce(0) { $0 + $1.price } / Double(recentPrices.count)
        let olderAvg = olderPrices.reduce(0) { $0 + $1.price } / Double(olderPrices.count)

        let difference = recentAvg - olderAvg

        if abs(difference) < 0.10 {
            return ("minus", "Price stable over the past week", .blue)
        } else if difference < 0 {
            return ("arrow.down.circle.fill", "Price trending down! Good time to buy", .green)
        } else {
            return ("arrow.up.circle.fill", "Price trending up recently", .orange)
        }
    }
}

struct PriceStatCard: View {
    let title: String
    let value: Double
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text("$\(value, specifier: "%.2f")")
                .font(.headline)
                .foregroundColor(color)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.1))
        .cornerRadius(8)
    }
}

struct EnhancedPriceHistoryChart_Previews: PreviewProvider {
    static var previews: some View {
        EnhancedPriceHistoryChart(product: Product(
            barcode: "123456",
            name: "Sample Product",
            brand: "Brand",
            imageUrl: nil,
            category: "Grocery",
            prices: [
                PriceEntry(
                    store: Store(name: "Loblaws", logo: "cart.fill", distance: 1.2),
                    price: 4.99,
                    regularPrice: 5.99,
                    saleEndDate: nil,
                    unitPrice: "$1.25/100g",
                    inStock: true,
                    lastUpdated: Date()
                )
            ]
        ))
        .padding()
    }
}
