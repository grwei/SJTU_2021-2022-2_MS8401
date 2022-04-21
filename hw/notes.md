# notes

## Homework 1

1. 先 detrend 得 SST_detr
2. 按月计算均值（monthly climatology）SST_cli
3. 按月计算 SST_ano = SST_detr - SST_cli 序列

### Data

- [NOAA Extended Reconstructed Sea Surface Temperature (SST) V5](https://psl.noaa.gov/data/gridded/data.noaa.ersst.v5.html)
  - Data: [Sea Surface Temperature (Monthly Mean)](https://downloads.psl.noaa.gov/Datasets/noaa.ersst.v5/sst.mnmean.nc)
  - [PSL Climate Research Data Resources and Help](https://psl.noaa.gov/data/gridded/help.html)
    - [Data Resources: Display and Analysis tools that read PSL's netCDF files](https://psl.noaa.gov/data/gridded_help/tools.html#matlab)

### Toolbox
