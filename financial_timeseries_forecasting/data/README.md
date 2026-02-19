**Data Sources**

The dataset contains daily historical stock prices for [NVDIA](https://www.nasdaq.com/market-activity/stocks/nvda/historical), covering the period from 31/01/2021 to 31/01/2026. 

The data was downloaded from [NASDAQ](https://www.nasdaq.com/).

Although the original file includes several columns, only two are used in the analysis:

* Date - to create the time index
* Close/Last - used as the financial time series for forecasting

The remaining columns (Open, High, Low, Volume) are kept for reference but are not used in modelling.
