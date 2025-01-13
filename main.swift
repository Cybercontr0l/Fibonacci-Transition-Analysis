import Foundation

// MARK: - Model for price data
struct PriceData: Decodable {
    let prices: [[Double]]
}

// MARK: - Function to fetch data from CoinGecko API
func fetchHistoricalData(from startDate: Int, to endDate: Int, completion: @escaping ([Double]?) -> Void) {
    let coinID = "mines-of-dalarnia"
    let vsCurrency = "usd"
    
    let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart/range?vs_currency=\(vsCurrency)&from=\(startDate)&to=\(endDate)")!

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
            completion(nil)
            return
        }

        do {
            // Print the full response to inspect the data structure
            if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Full response: \(responseObject)")
            }
            
            let response = try JSONDecoder().decode(PriceData.self, from: data)
            let prices = response.prices.map { $0[1] } // Extract only prices
            completion(prices)
        } catch {
            print("Error decoding data: \(error)")
            completion(nil)
        }
    }
    task.resume()
}

// MARK: - Function to calculate Fibonacci levels
func calculateFibonacciLevels(minPrice: Double, maxPrice: Double) -> [String: Double] {
    guard minPrice <= maxPrice else {
        fatalError("The minimum price must be less than or equal to the maximum price.")
    }

    let diff = maxPrice - minPrice
    return [
        "fib0": minPrice,
        "fib0382": minPrice + 0.382 * diff,
        "fib05": minPrice + 0.5 * diff,
        "fib0618": minPrice + 0.618 * diff,
        "fib0786": minPrice + 0.786 * diff,
        "fib1": maxPrice
    ]
}

// MARK: - Function to classify states
func classifyStates(prices: [Double], levels: [String: Double]) -> [String] {
    let fib0 = levels["fib0"]!
    let fib0382 = levels["fib0382"]!
    let fib05 = levels["fib05"]!
    let fib0618 = levels["fib0618"]!
    let fib0786 = levels["fib0786"]!
    let fib1 = levels["fib1"]!

    return prices.map { price in
        switch price {
        case fib0618...fib1: return "S1"
        case fib05..<fib0618: return "S2"
        case fib0382..<fib05: return "S3"
        case fib0..<fib0382: return "S4"
        default: return "S5"
        }
    }
}

// MARK: - Function to build the transition probability matrix
func buildTransitionMatrix(states: [String]) -> [[Double]] {
    let uniqueStates = Array(Set(states))
    var transitions = [String: [String: Int]]()

    // Initialization
    uniqueStates.forEach { state in
        transitions[state] = [:]
        uniqueStates.forEach { nextState in
            transitions[state]![nextState] = 0
        }
    }

    // Count transitions
    for i in 0..<states.count - 1 {
        let currentState = states[i]
        let nextState = states[i + 1]
        transitions[currentState]?[nextState, default: 0] += 1
    }

    // Normalize
    var matrix = [[Double]]()
    for state in uniqueStates {
        let totalTransitions = transitions[state]?.values.reduce(0, +) ?? 1
        let row = uniqueStates.map { nextState in
            Double(transitions[state]?[nextState] ?? 0) / Double(totalTransitions)
        }
        matrix.append(row)
    }

    return matrix
}

// Example of creating a timestamp from a string in "yyyy-MM-dd" format
func createTimestamp(from dateString: String) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let date = dateFormatter.date(from: dateString) else {
        fatalError("Invalid date format")
    }
    return Int(date.timeIntervalSince1970)
}

// Example of setting start and end dates
let startDateString = "2024-06-15" // Specify your start date in the format "yyyy-MM-dd"
let endDateString = "2025-01-01" // Specify your end date in the format "yyyy-MM-dd"

let startDate = createTimestamp(from: startDateString)
let endDate = createTimestamp(from: endDateString)

let minPrice = 0.15 // Specify your minimum price for the Fibonacci 0 level
let maxPrice = 0.217 // Specify your maximum price for the Fibonacci 1 level

// MARK: - Main program execution
fetchHistoricalData(from: startDate, to: endDate) { priceData in
    guard let priceData = priceData else { return }

    // Calculate Fibonacci levels
    let levels = calculateFibonacciLevels(minPrice: minPrice, maxPrice: maxPrice)

    // Output levels
    print("Recommended Fibonacci levels for buying and selling:")
    print("Buy 20% at level 0.618: \(levels["fib0618"]!)")
    print("Sell at level 0.786: \(levels["fib0786"]!)")
    print("If unable to sell, buy 30% at level 0.5: \(levels["fib05"]!)")
    print("Sell at level 0.618: \(levels["fib0618"]!)")
    print("If unable to sell, buy 50% at level 0.382: \(levels["fib0382"]!)")
    print("Sell at level 0.5: \(levels["fib05"]!)")
    
    // Classify states
    let states = classifyStates(prices: priceData, levels: levels)

    // Build the transition probability matrix
    let transitionMatrix = buildTransitionMatrix(states: states)

    // Output the matrix
    print("Transition matrix:")
    transitionMatrix.forEach { row in
        print(row.map { String(format: "%.2f", $0) }.joined(separator: " "))
    }
}

RunLoop.main.run()
