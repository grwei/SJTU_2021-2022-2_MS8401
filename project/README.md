# SJTU_2021-2022-2_MS8401 (project: seasonal adjustment-classical decomposition)

研-MS8401-44000-M01-海洋环境数据分析 (2022 Spring)

- [课程主页](https://grwei.github.io/SJTU_2021-2022-2_MS8401/)  
- [个人主页](https://grwei.github.io/)

## Contents

### Question

1. 什么视角？回顾(可用"未来"资料) or 实况/预报(只用当前及过去的资料)？
   1. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 的 Fig. 6：回顾视角，trend 的决定方式
2. WMO 气候态定义([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2))：过去 30 年平均，每 10 年更新
3. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 认为非线性趋势影响大，是否因非线性趋势总增长量大？应控制变量。另，若非线性程度更高？
4. ([Chen, X., and T. Li, 2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 用有限差分近似二阶微分。若用更高阶的近似方法？
5. [Introduction to Time Series and Forecasting](https://doi.org/10.1007/978-3-319-29854-2) (Peter J. Brockwell, Richard A. Davis, 2016) 第 1.5 节：(1) 先粗去 trend (P 点滑动平均，P 为 seasonal cycle），再简单平均求 seasonality；(2) 对 deseason 的原数据，重求 trend. [作为方案三：修正 trend! 对比方案一：若不修正，则 residue(anomaly) 中有 trend! (此处可用非参数趋势检验)]
6. Estemated and remove the trend and seasonal components (deterministic) to get stationary residuals?
7. The two approaches to trend and seasonality removal: (1) by estimation of mt and st in (1.5.1), and (2) by differencing the raw series. (p.21, Peter J. Brockwell, Richard A. Davis, [2016](https://doi.org/10.1007/978-3-319-29854-2))
8. 另一 idea：用 Exponential smoothing, (p.23, Peter J. Brockwell, Richard A. Davis, [2016](https://doi.org/10.1007/978-3-319-29854-2)) 与 Chen, X., and T. Li, ([2021](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2)) 对比. 再用更高阶导数的有限差分，重复.
9. idea: 从历史视角，比较以下方案：(a) 粗决定并去除 trend -> 决定 seasonality, (b) 粗决定并去除 trend -> 决定，并从原始数据中去除 seasonality -> 重决定 trend, (c) LSE，同时决定 seasonality 和 多项式 trend, (d) 决定并去除 seasonality -> 决定 trend. 评价指标：理想试验，MSE; 真实序列：CVE.

## Resources

### Toolbox

- [SEA-MAT: Matlab Tools for Oceanographic Analysis](https://sea-mat.github.io/sea-mat/)
- [M_Map: A mapping package for Matlab](https://www.eoas.ubc.ca/~rich/map.html)
- [Climate Data Toolbox for Matlab](https://github.com/chadagreene/CDT)

### References

- [An Improved Method for Defining Short-Term Climate Anomalies](http://jmr.cmsjournal.net/en/article/doi/10.1007/s13351-021-1139-2) (2021)
  - [中文解读：一种新的气候异常定义方法及其应用](https://mp.weixin.qq.com/s/s5-IaYUFE5S5JdOQ75unYg)
- [Optimal Estimation of the Climatological Mean](https://doi.org/10.1175/2009JCLI2944.1) (2010)
- Brockwell, P.J., Davis, R.A. (2016). Introduction. In: Introduction to Time Series and Forecasting. Springer Texts in Statistics. Springer, Cham. [https://doi.org/10.1007/978-3-319-29854-2_1](https://doi.org/10.1007/978-3-319-29854-2_1)
- [Detrending climate time series—an evaluation of Empirical Mode Decomposition](https://blogs.ubc.ca/colinmahony/2013/12/14/detrending/#:~:text=Effect%20of%20detrending%20on%20climate-year%20classification%20Detrending%20reduces,of%20BEC%20variants%20in%20a%20climate%20year%20classification.) (2013)

#### Others

- [An introduction to time series forecasting](https://www.infoworld.com/article/3622246/an-introduction-to-time-series-forecasting.html)
- [Trend and Seasonal Components](https://webspace.maths.qmul.ac.uk/b.bogacka/TimeSeries/TS_Chapter2_1.pdf)
- [What we talk about when we talk about seasonality – A transdisciplinary review](https://doi.org/10.1016/j.earscirev.2021.103843) (2022)
- [The Variability of Seasonality](https://doi.org/10.1175/JCLI-3256.1) (2005)
- [The impact of global warming on sea surface temperature based El Niño–Southern Oscillation monitoring indices](https://doi.org/10.1002/joc.5864) (2018)
- [Spectral representation of the annual cycle in the climate change signal](https://doi.org/10.5194/hess-15-2777-2011) (2011)
- [Sea Surface Temperatures: Seasonal Persistence and Trends](https://doi.org/10.1175/JTECH-D-19-0090.1) (2019)
- [Quantile Trend Regression and Its Application to Central England Temperature](https://doi.org/10.3390/math10030413) (2022)
- [Trend analysis of climate time series: A review of methods](https://doi.org/10.1016/j.earscirev.2018.12.005) (2018)
- [Changes in the Seasonal Cycle of Temperature and Atmospheric Circulation](https://doi.org/10.1175/JCLI-D-11-00470.1)
- [On the trend, detrending, and variability of nonlinear and nonstationary time series](https://doi.org/10.1073/pnas.0701020104)
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
