# notes

## Homework 1

1. 先 detrend 得 SST_detr
2. 按月计算均值（monthly climatology）SST_cli
3. 按月计算 SST_ano = SST_detr - SST_cli 序列

## Notes on the trends, change, variability and anomaly of a time series

(0) 基本问题

1. trend, change, variability and anomaly 的数学定义？
2. [`detrend`](https://ww2.mathworks.cn/help/matlab/ref/detrend.html) 算法的详细实现方式？

(1) Definition.
$x(t) = \mathop{\mathrm{Tr}}(x(t)) + \mathop{\mathrm{Va}}(x(t)),$  
$x(t) = \overline{x} + x'(t).$  

(2)
$[\mathop{\mathrm{Va}}(x(t))]' := [x(t) - \mathop{\mathrm{Tr}}(x(t))]' = x'(t) - [\mathop{\mathrm{Tr}}(x(t))]',$  
$\mathop{\mathrm{Va}}(x'(t)) = x' - \mathop{\mathrm{Tr}}(x'(t)).$  

(3)
$[\mathop{\mathrm{Tr}}(x(t))]' = \mathop{\mathrm{Tr}}(x(t)) - \overline{\mathop{\mathrm{Tr}}(x(t))},$
$\mathop{\mathrm{Tr}}(x'(t)) = \mathop{\mathrm{Tr}}(x(t) - \overline{x}) = \mathop{\mathrm{Tr}}(x(t)) - \overline{x}.$

(3.1)
Assumes that $\mathop{\mathrm{Tr}}(x(t))$ is linear about $t$ (but not necessarily linear about $x(t)$), we have (线性回归曲线通过样本均值点)

$$\overline{\mathop{\mathrm{Tr}}(x(t))} = A \overline{t} + B = \overline{x},$$

where $A$, $B$ depends on $x(t)$ (not on $t$). Hence $[\mathop{\mathrm{Tr}}(x(t))]' = \mathop{\mathrm{Tr}}(x'(t))$ and $[\mathop{\mathrm{Va}}(x(t))]' = \mathop{\mathrm{Va}}(x'(t)).$

(3.2) 

### Data

- [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)
  - Data: [Sea Surface Temperature (Monthly Mean)](https://downloads.psl.noaa.gov/Datasets/noaa.ersst.v5/sst.mnmean.nc)
  - [PSL Climate Research Data Resources and Help](https://psl.noaa.gov/data/gridded/help.html)
    - [Data Resources: Display and Analysis tools that read PSL's netCDF files](https://psl.noaa.gov/data/gridded_help/tools.html#matlab)

### Toolbox

- [Climate Data Tools for Matlab](https://github.com/chadagreene/CDT)
  - [CDT/season_documentation/How this function works](https://www.chadagreene.com/CDT/season_documentation.html#16)
