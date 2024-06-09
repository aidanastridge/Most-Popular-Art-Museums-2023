#  Most Popular Art Museums 2023

### Step 1: Import
```r
art_df <- read.csv('most_popular_art_museums.csv')
geo_df <- read.csv('worldcities.csv')
```

Imported The Art Museums "Most Popular Art Museums of 2023" dataset. The prior dataset has 100 observations.
I also imported the World Cities Database so I could join on City gaining Country.

### Step 2: Joining and filtering

```r
joined_df <- merge(art_df,geo_df,by.x = "CITY", by.y = "city") 
```
Unfortunatly, we have 225 observations now due to connections like Paris, Texas and Paris, France. I'm going have to filter those out! Great news, the World Cities Database has a column that points out Capital cities.

```r
filtered_df <- filter(joined_df, capital != '')
```
Now there is 76 observations – 24 observations less then the original dataset.

```r
subset_df <- art_df[ ! art_df$MUSEUM %in% NAMES_List, ]
```

31 + 76 = 107.
Huh? 7 more observations than before?
Looking at the filtered dataframe (76 observations), there are repeated Museums.

Cleaning up the latter, and adding Countries to the former, I now can join them all together to get back to the original 100 observations.
Excel is your best friend when you have to edit datasets at base level.

```r
write.csv(filtered_df,'/Users/aidanastridge/Documents/project/1.csv')
write.csv(subset_df,'/Users/aidanastridge/Documents/project/2.csv')
```

```r
subset_df <- art_df[ ! art_df$MUSEUM %in% NAMES_List, ]
```

```r
data <- read.csv('final.csv')

#echarts4r choropleth recognizes South Korea as Korea and North Korea as the Democratic People's Republic of Korea

data$country <- gsub('Korea, South','Korea',data$country)

country_count <- data %>%
  count(country)

data <- merge(data,country_count,by.x = "country", by.y = "country")
```

### Step 3: Plotting

```r
library(tidyverse)
library(rhino)
library(echarts4r)

data %>%
  e_charts(country) %>%
  e_map(TOTAL, map = "world") %>%
  e_visual_map(TOTAL) %>%
  e_title("Choropleth Total")

```

