# SJTU_2021-2022-2_MS8401 (project: seasonal adjustment-classical decomposition)

研-MS8401-44000-M01-海洋环境数据分析 (2022 Spring)

- [课程主页](https://grwei.github.io/SJTU_2021-2022-2_MS8401/)  
- [个人主页](https://grwei.github.io/)

## Contents

- [Report](doc/课程项目_危国锐_small.pdf)

### Question

1. 什么视角？回顾(retrospective, 可用"未来"资料, goal: for analysis) or 实况/预报(forecasting, 只用当前及过去的资料, goal: for prediction)？
   1. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 的 Fig. 6：回顾视角，trend 的决定方式
2. WMO 气候态定义([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2))：过去 30 年平均，每 10 年更新
3. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 认为非线性趋势影响大，是否因非线性趋势总增长量大？应控制变量。另，若非线性程度更高？
4. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 用有限差分近似二阶微分。若用更高阶的近似方法？
5. [Introduction to Time Series and Forecasting](https://doi.org/10.1007/978-3-319-29854-2) (Peter J. Brockwell, Richard A. Davis, 2016) 第 1.5 节：(1) 先粗去 trend (P 点滑动平均，P 为 seasonal cycle），再简单平均求 seasonality；(2) 对 deseason 的原数据，重求 trend. [作为方案三：修正 trend! 对比方案一：若不修正，则 residue(anomaly) 中有 trend! (此处可用非参数趋势检验)]
6. Estemated and remove the trend and seasonal components (deterministic) to get stationary residuals?
7. The two approaches to trend and seasonality removal: (1) by estimation of mt and st in (1.5.1), and (2) by differencing the raw series. (p.21, Peter J. Brockwell, Richard A. Davis, [2016](https://doi.org/10.1007/978-3-319-29854-2))
8. 另一 idea：用 Exponential smoothing, (p.23, Peter J. Brockwell, Richard A. Davis, [2016](https://doi.org/10.1007/978-3-319-29854-2)) 与 Chen, X., and T. Li, ([2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 对比.
9. idea:
   1. 回顾(retrospective)视角，比较以下方案：(a) 粗决定并去除 trend -> 决定 seasonality, (b) 粗决定并去除 trend -> 决定，并从原始数据中去除 seasonality -> 重决定 trend, (c) LSE，同时决定 seasonality 和 多项式 trend, (d) 决定并去除 seasonality (用 MA) -> 决定 trend. 评价指标：理想试验，MSE; 真实序列：CVE. 参考 Narapusetty, B., DelSole, T., & Tippett, M. K. ([2009](https://doi.org/10.1175/2009JCLI2944.1))
   2. (不讨论. 原因："The assumption is that the predictive models have to be process-based, not data-driven." (Wu et.al., [2007](https://doi.org/10.1073/pnas.0701020104))) 预报视角，比较：WMO 经典定义法，趋势校正法 (Chen, X., and T. Li, [2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2))，Exponential smoothing (选 alpha)，单侧局部线性回归. 指标：重复 (Chen, X., and T. Li, [2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)).
   3. implications: 关注 variability 的工作，建议增加 采取数种时间序列分解方法 的讨论.
10. 更新的 idea:
    1. 回顾(retrospective)视角，比较以下方案：(1a) 决定 trend -> 决定 seasonality, (1b) 决定 seasonality -> 决定 trend, (2) 再迭代一次, (3) 线性回归，同时决定 trend 和 seasonality, (4) Nino-X like: 先去 annual cycle, 再滑动平均? Narapusetty, B., DelSole, T., & Tippett, M. K. ([2009](https://doi.org/10.1175/2009JCLI2944.1))
       1. 理想试验：M2, M2A 几乎无差异；trend 接近 M1b, seasonality 接近 M1a.
    2. intrinsic/adaptive means of trend extraction: Empirical Mode Decomposition (EMD); locally weighted linear regression (LOWESS)
11. 建议保证 annual, residue 零均值.
12. 题目：对几种分解方案的比较及其暗示
13. 讨论：气候系统的非线性 -> 加性分解不好，不可能分开

## Resources

### Toolbox

- [SEA-MAT: Matlab Tools for Oceanographic Analysis](https://sea-mat.github.io/sea-mat/)
- [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
- [Climate Data Toolbox for Matlab](https://github.com/chadagreene/CDT)

### References

- [An Improved Method for Defining Short-Term Climate Anomalies](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2) (2021)
  - [中文解读：一种新的气候异常定义方法及其应用](https://mp.weixin.qq.com/s/s5-IaYUFE5S5JdOQ75unYg)
- Optimal Estimation of the Climatological Mean (Narapusetty, Balachandrudu, Timothy DelSole, and Michael K. Tippett., [2009](https://doi.org/10.1175/2009JCLI2944.1))
- The Variability of Seasonality (Pezzulli, S., D. B. Stephenson, and A. Hannachi., [2005](https://doi.org/10.1175/JCLI-3256.1))
- On the trend, detrending, and variability of nonlinear and nonstationary time series (Wu et.al., [2007](https://doi.org/10.1073/pnas.0701020104))
  - [Detrending climate time series—an evaluation of Empirical Mode Decomposition](https://blogs.ubc.ca/colinmahony/2013/12/14/) (2013)
  - [Empirical mode decomposition (Matlab)](https://ww2.mathworks.cn/help/signal/ref/emd.html)
- Brockwell, P.J., Davis, R.A. ([2016](https://doi.org/10.1007/978-3-319-29854-2_1)). Introduction. In: Introduction to Time Series and Forecasting. Springer Texts in Statistics. Springer, Cham.

#### Others

- The Analysis of Time Series: An Introduction with R (Chris Chatfield, Haipeng Xing, [2019](https://doi.org/10.1201/9781351259446))
- [Seasonal Adjustment (Matlab)](https://ww2.mathworks.cn/help/econ/seasonal-adjustment-1.html)
  - [The X12 Procedure](https://tds.sas.com/rnd/app/ets/procedures/ets_x12.html)
- [An introduction to time series forecasting](https://www.infoworld.com/article/3622246/an-introduction-to-time-series-forecasting.html)
  - [Trend and Seasonal Components](https://webspace.maths.qmul.ac.uk/b.bogacka/TimeSeries/TS_Chapter2_1.pdf)
- [What we talk about when we talk about seasonality – A transdisciplinary review](https://doi.org/10.1016/j.earscirev.2021.103843) (2022)
- [The impact of global warming on sea surface temperature based El Niño–Southern Oscillation monitoring indices](https://doi.org/10.1002/joc.5864) (2018)
- [Spectral representation of the annual cycle in the climate change signal](https://doi.org/10.5194/hess-15-2777-2011) (2011)
- [Sea Surface Temperatures: Seasonal Persistence and Trends](https://doi.org/10.1175/JTECH-D-19-0090.1) (2019)
- [Quantile Trend Regression and Its Application to Central England Temperature](https://doi.org/10.3390/math10030413) (2022)
- [Trend analysis of climate time series: A review of methods](https://doi.org/10.1016/j.earscirev.2018.12.005) (2018)
- [Changes in the Seasonal Cycle of Temperature and Atmospheric Circulation](https://doi.org/10.1175/JCLI-D-11-00470.1)
- [A Nonparametric Approach to the Removal of Documented Inhomogeneities in Climate Time Series](https://doi.org/10.1175/JAMC-D-12-0166.1) (2013)

#### Technical

- [Nino X 定义](https://climatedataguide.ucar.edu/climate-data/nino-sst-indices-nino-12-3-34-4-oni-and-tni)
- [Analysis Tools and Methods](https://climatedataguide.ucar.edu/climate-data-tools-and-analysis/statistical-diagnostic-methods-overview)
- [How to Decompose Time Series Data into Trend and Seasonality](https://machinelearningmastery.com/decompose-time-series-data-trend-seasonality/)
- [Why do we detrend or remove seasonality from a data when doing time series analysis?](https://stats.stackexchange.com/questions/395830/why-do-we-detrend-or-remove-seasonality-from-a-data-when-doing-time-series-analy)
- [Time Series - How to Remove Trend & Seasonality from Time-Series Data using Pandas [Python]](https://coderzcolumn.com/tutorials/data-science/how-to-remove-trend-and-seasonality-from-time-series-data-using-python-pandas)

## Contact information

- Guorui Wei (危国锐)
- E-mail: 313017602@qq.com; weiguorui@sjtu.edu.cn
- Website: [https://grwei.github.io/](https://grwei.github.io/)
