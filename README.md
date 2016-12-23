# haploR: utilities for mining Haploreg and other similar web-based tools

## Installation

### Development version

The last version of ```haploR``` that is compatible with the current version of R (3.3), 
which can be downloaded using devtools:

```
devtools::install_github("izhbannikov/haploR")
```

## Usage

```
library(haploR)
data <- queryHaploreg("rs10048158")
head(data)
```