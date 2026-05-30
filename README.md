# Walk-Forward Analysis — MQL4 Script

A MetaTrader 4 script that performs a **walk-forward optimization and out-of-sample validation framework** on a simple buy-on-close-above-open strategy by splitting historical bar data into sequential in-sample training windows and out-of-sample testing windows, optimizing a moving average period parameter via `OptimizeStrategy()` brute-force search on the training window, applying the best-found parameter to the out-of-sample test window via `TestStrategy()`, and aggregating total profit and trade count across all walk-forward steps.

---

## Overview

Walk-forward analysis is the gold standard methodology for validating the robustness of a trading strategy against overfitting. The core problem with standard backtesting is data snooping bias: when a strategy is optimized on the same historical data it will later be evaluated against, the optimized parameters inevitably reflect the specific noise patterns of that dataset rather than genuine edge — a phenomenon known as curve fitting. Walk-forward analysis addresses this by splitting the historical data into a series of sequential windows: an in-sample period for optimization, followed by an immediately succeeding out-of-sample period for testing. This sequence advances forward through the historical record in a rolling manner — like a sliding window — so that each test segment is data the optimizer has never seen. If the strategy's edge is genuine, the optimized parameters found on in-sample data should produce positive results on the subsequent out-of-sample window. If performance collapses out-of-sample, the apparent backtest edge was a statistical artifact. This script implements a simplified but structurally correct walk-forward framework as a template for building strategy validation pipelines inside MT4.

---

## Features

- **Sequential walk-forward loop** — `for (startBar = totalBars − WalkForwardSteps; startBar > WalkForwardSteps; startBar -= WalkForwardSteps)`: iterates backward through history in `WalkForwardSteps`-sized increments, ensuring each step is isolated
- **In-sample / out-of-sample split** — `trainingBars = (int)(WalkForwardSteps × TrainingPercentage / 100.0)`; `testingBars = WalkForwardSteps − trainingBars`; configurable `TrainingPercentage` default `70%`
- **`OptimizeStrategy()` brute-force period search** — iterates `period = 10` to `50` in steps of `5`; calls `SimulateStrategy(startBar, trainingBars, period)` for each; returns `bestParameter` (period) producing highest `SimulateStrategy()` profit
- **`SimulateStrategy()` close-above-open logic** — iterates `i = startBar` down to `startBar − bars`; `close > open` → buy: `profit += (close − open) × parameter × MarketInfo(MODE_TICKVALUE)`; `TotalTrades++`; `AccountBalance += profit`
- **`TestStrategy()` out-of-sample application** — calls `SimulateStrategy(startBar − trainingBars, testingBars, optimizedParameter)` with the parameter found in the training phase; returns out-of-sample profit
- **`StartingBalance` virtual account** — `AccountBalance = StartingBalance` initialized before the walk-forward loop; each step increments `AccountBalance += profit`; final balance printed on completion
- **Step-by-step result logging** — each walk-forward step prints: `Training Bars`, `Testing Bars`, best parameter, step profit, `Total Profit`, and `Total Trades` to the Experts tab for full auditability

---

## How It Works

1. Input validation: `TrainingPercentage` in `(0, 100)`; `iBars() <= WalkForwardSteps` aborts with log
2. Walk-forward loop iterates history in `WalkForwardSteps` blocks
3. Per step: `OptimizeStrategy()` finds best MA period on training window; `TestStrategy()` applies it to test window
4. `TotalProfit += profit`; results printed per step
5. Final balance and totals printed on loop completion

---

## Input Parameters

| Parameter              | Type            | Default      | Description                                                             |
|------------------------|-----------------|--------------|-------------------------------------------------------------------------|
| `TrainingPercentage`   | double          | `70.0`       | Percentage of each walk-forward window used for in-sample optimization  |
| `WalkForwardSteps`     | int             | `50`         | Number of bars per walk-forward window (training + testing combined)    |
| `Timeframe`            | ENUM_TIMEFRAMES | `PERIOD_H1`  | Timeframe for bar data                                                  |
| `StartingBalance`      | double          | `10000.0`    | Initial virtual account balance for cumulative P&L tracking             |

---

## Output Format (Experts Log)

```
Training Phase: 35 bars. Testing Phase: 15 bars with parameter: 25
Step Profit: 42.50 | Total Profit: 42.50
Walk-Forward Analysis Complete. Final Balance: 10042.50 | Total Profit: 42.50 | Total Trades: 7
```

---

## Installation

1. Copy `Walk_forward_Analysis.mq4` to `MQL4/Scripts/` in your MT4 data folder
2. Compile in MetaEditor (F7)
3. Drag onto any chart from Navigator → Scripts
4. Configure inputs and click **OK**
5. Review walk-forward results in the **Experts** tab

> **Note:** This script implements a simplified fixed-parameter strategy (close > open) as the simulation engine. Replace `SimulateStrategy()` with your actual strategy logic to perform genuine walk-forward validation on your own system.

---

## Requirements

- MetaTrader 4 (`#property strict` compatible build)
- MQL4 compiler (MetaEditor)

---

## License

MIT License

Copyright (c) 2026

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
