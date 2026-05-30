//+------------------------------------------------------------------+
//|                           WalkForwardAnalysis.mq4                |
//|          Performs Walk-Forward Analysis on Historical Data       |
//+------------------------------------------------------------------+
#property strict

// Input parameters
input double TrainingPercentage = 70.0;   // Percentage of data for training
input int WalkForwardSteps = 50;         // Number of candles in each walk-forward step
input ENUM_TIMEFRAMES Timeframe = PERIOD_H1; // Timeframe for the analysis
input double StartingBalance = 10000.0;  // Initial virtual account balance

// Global variables
double AccountBalance;
double TotalProfit = 0.0;
int TotalTrades = 0;

//+------------------------------------------------------------------+
//| Main Function                                                   |
//+------------------------------------------------------------------+
void OnStart()
{
   // Validate inputs
   if (TrainingPercentage <= 0 || TrainingPercentage >= 100) {
      Print("Invalid TrainingPercentage. It must be between 0 and 100.");
      return;
   }

   // Get the total number of historical candles
   int totalBars = iBars(Symbol(), Timeframe);
   if (totalBars <= WalkForwardSteps) {
      Print("Not enough historical data for Walk-Forward Analysis.");
      return;
   }

   AccountBalance = StartingBalance;

   // Perform walk-forward analysis
   for (int startBar = totalBars - WalkForwardSteps; startBar > WalkForwardSteps; startBar -= WalkForwardSteps) {
      int trainingBars = (int)(WalkForwardSteps * (TrainingPercentage / 100.0));
      int testingBars = WalkForwardSteps - trainingBars;

      // Training phase
      Print("Training Phase: ", trainingBars, " bars.");
      double optimizedParameter = OptimizeStrategy(startBar, trainingBars);

      // Testing phase
      Print("Testing Phase: ", testingBars, " bars with parameter: ", optimizedParameter);
      double profit = TestStrategy(startBar - trainingBars, testingBars, optimizedParameter);

      TotalProfit += profit;
      Print("Step Profit: ", profit, " | Total Profit: ", TotalProfit);
   }

   Print("Walk-Forward Analysis Complete. Final Balance: ", AccountBalance, 
         " | Total Profit: ", TotalProfit, " | Total Trades: ", TotalTrades);
}

//+------------------------------------------------------------------+
//| Optimizes Strategy on Training Data                             |
//+------------------------------------------------------------------+
double OptimizeStrategy(int startBar, int trainingBars)
{
   // Example: Find the best moving average period for training data
   double bestProfit = -DBL_MAX;
   double bestParameter = 0;

   for (double period = 10; period <= 50; period += 5) {
      double profit = SimulateStrategy(startBar, trainingBars, period);
      if (profit > bestProfit) {
         bestProfit = profit;
         bestParameter = period;
      }
   }

   Print("Best Parameter Found: ", bestParameter, " | Profit: ", bestProfit);
   return bestParameter;
}

//+------------------------------------------------------------------+
//| Tests Strategy on Out-of-Sample Data                            |
//+------------------------------------------------------------------+
double TestStrategy(int startBar, int testingBars, double parameter)
{
   return SimulateStrategy(startBar, testingBars, parameter);
}

//+------------------------------------------------------------------+
//| Simulates Strategy                                               |
//+------------------------------------------------------------------+
double SimulateStrategy(int startBar, int bars, double parameter)
{
   double profit = 0.0;
   for (int i = startBar; i > startBar - bars; i--) {
      if (i < 0) break;

      double open = iOpen(Symbol(), Timeframe, i);
      double close = iClose(Symbol(), Timeframe, i);

      // Example logic: Buy if Close > Open
      if (close > open) {
         profit += (close - open) * parameter * MarketInfo(Symbol(), MODE_TICKVALUE);
         TotalTrades++;
      }
   }

   AccountBalance += profit;
   return profit;
}
