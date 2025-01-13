Fibonacci Transition Analysis

Overview

This project provides a Swift-based financial analysis tool for cryptocurrency market data. It calculates Fibonacci retracement levels, classifies market states, and builds a transition probability matrix to analyze market trends and probabilities based on historical price data. The tool uses the CoinGecko API for fetching historical cryptocurrency price data.

Features

Historical Data Fetching: Fetch cryptocurrency price data for a specific date range using the CoinGecko API.
Fibonacci Levels Calculation: Automatically compute Fibonacci retracement levels based on user-defined minimum and maximum prices.
State Classification: Classify price data into states based on calculated Fibonacci levels.
Transition Matrix: Generate a transition probability matrix to analyze the likelihood of moving between states.
Extensibility: Easily adapt to other coins, date ranges, or currencies by changing input parameters.
How It Works

Data Fetching:
The app retrieves historical price data for a specific coin and currency via the CoinGecko API.
Fibonacci Levels Calculation:
Based on user-defined min and max prices, it computes the key Fibonacci retracement levels (0, 0.382, 0.5, 0.618, 0.786, 1).
State Classification:
Each price point is classified into one of five states (S1, S2, S3, S4, or S5) based on which Fibonacci level range it falls into.
Transition Matrix Generation:
A Markov chain is generated to model state transitions, providing insights into market movement probabilities.
Technologies Used

Swift: The application is written entirely in Swift, utilizing its robust features for data fetching, parsing, and computation.
URLSession: Used for API requests to fetch data from CoinGecko.
JSONDecoder: Handles decoding of API responses into structured Swift models.
Foundation: Provides essential utilities for date formatting, mathematical operations, and more.
Getting Started

Prerequisites
Xcode: Ensure you have Xcode installed on your Mac.
API Access: No special API key is required to use the CoinGecko API.
Steps
Clone the repository:
git clone https://github.com/yourusername/fibonacci-transition-analysis.git
cd fibonacci-transition-analysis
Open the project in Xcode.
Update parameters:
Edit startDateString and endDateString in the source code to specify the date range.
Set minPrice and maxPrice according to your analysis requirements.
Run the project to see the results in the console.
