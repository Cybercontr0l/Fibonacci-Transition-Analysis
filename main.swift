import Foundation

// MARK: - Модель для данных цены
struct PriceData: Decodable {
    let prices: [[Double]]
}

// MARK: - Функция для получения данных с CoinGecko API
func fetchHistoricalData(from startDate: Int, to endDate: Int, completion: @escaping ([Double]?) -> Void) {
    let coinID = "mines-of-dalarnia"
    let vsCurrency = "usd"
    
    let url = URL(string: "https://api.coingecko.com/api/v3/coins/\(coinID)/market_chart/range?vs_currency=\(vsCurrency)&from=\(startDate)&to=\(endDate)")!

    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data, error == nil else {
            print("Ошибка при запросе данных: \(error?.localizedDescription ?? "Неизвестная ошибка")")
            completion(nil)
            return
        }

        do {
            // Печать полного ответа для проверки структуры данных
            if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                print("Полный ответ: \(responseObject)")
            }
            
            let response = try JSONDecoder().decode(PriceData.self, from: data)
            let prices = response.prices.map { $0[1] } // Берем только цены
            completion(prices)
        } catch {
            print("Ошибка декодирования данных: \(error)")
            completion(nil)
        }
    }
    task.resume()
}

// MARK: - Функция для расчета уровней Фибоначчи
func calculateFibonacciLevels(minPrice: Double, maxPrice: Double) -> [String: Double] {
    guard minPrice <= maxPrice else {
        fatalError("Минимальная цена должна быть меньше или равна максимальной цене.")
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

// MARK: - Функция для классификации состояний
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

// MARK: - Функция для построения матрицы вероятностей переходов
func buildTransitionMatrix(states: [String]) -> [[Double]] {
    let uniqueStates = Array(Set(states))
    var transitions = [String: [String: Int]]()

    // Инициализация
    uniqueStates.forEach { state in
        transitions[state] = [:]
        uniqueStates.forEach { nextState in
            transitions[state]![nextState] = 0
        }
    }

    // Подсчет переходов
    for i in 0..<states.count - 1 {
        let currentState = states[i]
        let nextState = states[i + 1]
        transitions[currentState]?[nextState, default: 0] += 1
    }

    // Нормализация
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

// Пример создания даты из строки в формате "yyyy-MM-dd"
func createTimestamp(from dateString: String) -> Int {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    guard let date = dateFormatter.date(from: dateString) else {
        fatalError("Неверный формат даты")
    }
    return Int(date.timeIntervalSince1970)
}

// Пример задания начальной и конечной дат
let startDateString = "2024-06-15" // Задайте вашу начальную дату в формате "yyyy-MM-dd"
let endDateString = "2025-01-01" // Задайте вашу конечную дату в формате "yyyy-MM-dd"

let startDate = createTimestamp(from: startDateString)
let endDate = createTimestamp(from: endDateString)

let minPrice = 0.15 // Задайте вашу минимальную цену для точки 0 Фибоначчи
let maxPrice = 0.217 // Задайте вашу максимальную цену для точки 1 Фибоначчи

// MARK: - Основной запуск программы
fetchHistoricalData(from: startDate, to: endDate) { priceData in
    guard let priceData = priceData else { return }

    // Расчет уровней Фибоначчи
    let levels = calculateFibonacciLevels(minPrice: minPrice, maxPrice: maxPrice)

    // Вывод уровней
    print("Рекомендуемые уровни Фибоначчи для покупки и продажи:")
    print("Покупка 20% на уровне 0.618: \(levels["fib0618"]!)")
    print("Продажа на уровне 0.786: \(levels["fib0786"]!)")
    print("Если продажа не удается, покупка 30% на уровне 0.5: \(levels["fib05"]!)")
    print("Продажа на уровне 0.618: \(levels["fib0618"]!)")
    print("Если продажа не удается, покупка 50% на уровне 0.382: \(levels["fib0382"]!)")
    print("Продажа на уровне 0.5: \(levels["fib05"]!)")
    
    // Классификация состояний
    let states = classifyStates(prices: priceData, levels: levels)

    // Построение матрицы вероятностей переходов
    let transitionMatrix = buildTransitionMatrix(states: states)

    // Вывод матрицы
    print("Матрица переходов:")
    transitionMatrix.forEach { row in
        print(row.map { String(format: "%.2f", $0) }.joined(separator: " "))
    }
}

RunLoop.main.run()
