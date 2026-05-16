import Foundation
import Combine

class WeatherManager: ObservableObject {
    @Published var temperature: Int = 72
    @Published var condition: String = "Partly Cloudy"
    @Published var high: Int = 78
    @Published var low: Int = 64
    @Published var location: String = "San Francisco"

    private var timer: Timer?

    init() {
        // In a real app, this would fetch from WeatherKit or a weather API
        // For now, we mock it.
        mockWeatherUpdate()

        // Simulate minor temperature fluctuations every 30 seconds
        timer = Timer.scheduledTimer(withTimeInterval: 30, repeats: true) { [weak self] _ in
            let fluctuation = Int.random(in: -1...1)
            self?.temperature += fluctuation
        }
    }

    private func mockWeatherUpdate() {
        // Initial mock values
        temperature = 72
        condition = "Partly Cloudy"
        high = 78
        low = 64
        location = "San Francisco"
    }

    deinit {
        timer?.invalidate()
    }
}
