# haploR: utilities for querying Haploreg and other similar web-based tools

## Installation

### Development version

The last version of `haploR` that is compatible with the current version of R (3.3), 
which can be downloaded using devtools:

```
devtools::install_github("izhbannikov/haploR")
```

## Usage

### Querying Haploreg

```
library(haploR)
data <- queryHaploreg("rs10048158")
head(data)
```

#### For a particular study
```
library(haploR)
studies <- getStudyList()
studies[[2]]
queryHaploreg(study=studies[[2]])
```

###Querying RegulomeDB

```
library(haploR)
data <- queryRegulome(c("rs4791078","rs10048158"))
head(data)
```
