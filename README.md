#  Most Popular Art Museums

### Step 1: Import
```r
df <- read.csv('most_popular_art_museums.csv')
geo_df <- read.csv('worldcities.csv')
```

Imported The Art Museums "Most Popular Art Museums of 2023" dataset. The prior dataset has 100 observations.
I also imported the World Cities Database so I could join on City gaining Country, Longitude, and Latitude in the process.

### Step 2: Joining and filtering

```r
joined_df <- merge(df,geo_df,by.x = "CITY", by.y = "city") 
```
Unfortunatly, we have 225 observations now due to connections like Paris, Texas and Paris, France. I'm going have to filter those out! Great news, the World Cities Database has a column that points out Capital cities.

```r
filtered_df <- filter(joined_df, capital != '')
```
Now there is 76 observations – 24 observations less then the original dataset.

```r
sbdf <- df[ ! df$MUSEUM %in% NAMES_List, ]
```
31 + 76 = 107
Huh? 7 more observations than before?
Looking at the filtered dataframe (76 observations), there are repeated Museums.

### Step 3: Plotting

```r
library(tidyverse)
library(rhino)
```

