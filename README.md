#  Most Popular Art Museums

### Step 1: Import
```r
df <- read.csv('most_popular_art_museums.csv')
geo_df <- read.csv('worldcities.csv')
```

### Step 2: Joining and filtering
```r
joined_df <- merge(df,geo_df,by.x = "CITY", by.y = "city") 
```

