main_dir <- "~/Downloads/advancedR/CRND0103-202404080750"
folders <- list.dirs(main_dir, full.names = TRUE, recursive = FALSE)


station_info <- data.frame()

for (f in folders) {
  txt_files <- list.files(f, pattern = "\\.txt$", full.names = TRUE)
  for (t in txt_files) {
    d <- read.table(t)
    colnames(d) <- c("WBANNO", "LST_DATE", "CRX_VN", "LONGITUDE", "LATITUDE", "T_DAILY_MAX",
                     "T_DAILY_MIN", "T_DAILY_MEAN", "T_DAILY_AVG", "P_DAILY_CALC", "SOLARAD_DAILY",
                     "SUR_TEMP_DAILY_TYPE", "SUR_TEMP_DAILY_MAX", "SUR_TEMP_DAILY_MIN",
                     "SUR_TEMP_DAILY_AVG", "RH_DAILY_MAX", "RH_DAILY_MIN", "RH_DAILY_AVG",
                     "SOIL_MOISTURE_5_DAILY", "SOIL_MOISTURE_10_DAILY", "SOIL_MOISTURE_20_DAILY",
                     "SOIL_MOISTURE_50_DAILY", "SOIL_MOISTURE_100_DAILY", "SOIL_TEMP_5_DAILY",
                     "SOIL_TEMP_10_DAILY", "SOIL_TEMP_20_DAILY"," SOIL_TEMP_50_DAILY", "SOIL_TEMP_100_DAILY")
    station_identifier <- d[1, "WBANNO"]
    station_name <- sub("\\.txt$", "", strsplit(t, "-")[[1]][4])
    state <- substr(strsplit(t, "-")[[1]][4], 1, 2)
    longitude <- d[1, "LONGITUDE"]
    latitude <- d[1, "LATITUDE"]
    df <- data.frame(STATION_IDENTIFIER = station_identifier,
                     STATION_NAME = station_name,
                     STATE = state,
                     LONGITUDE = longitude,
                     LATITUDE = latitude,
                     stringsAsFactors = FALSE)
    station_info <- rbind(station_info, df)
    station_info <- unique(station_info)
  }
}

save(station_info, file = "~/Downloads/climateUSA/data/station_info.RData")
tools::resaveRdaFiles("~/Downloads/climateUSA/data/station_info.RData", compress = "xz")

# AK_Huslia_27_W and AK_Huslia_27_E have the same station identifier,
# and after checking the AK_Huslia_27_W data is in the AK_Huslia_27_E data,
# so remove AK_Huslia_27_W from the dataset
station_info <- subset(station_info, STATION_NAME != "AK_Huslia_27_W")


climate_data <- data.frame()

for (f in folders) {
  txt_files <- list.files(f, pattern = "\\.txt$", full.names = TRUE)
  for (t in txt_files) {
    df1 <- read.table(t)[ ,1:11]
    climate_data <- rbind(climate_data, df1)
  }
}

climate_data <- merge(climate_data, station_info, by.x = "V1", by.y = "STATION_IDENTIFIER", all.x = TRUE, all.y = FALSE)
colnames(climate_data) <- c("WBANNO", "LST_DATE", "CRX_VN", "LONGITUDE", "LATITUDE", "T_DAILY_MAX",
                        "T_DAILY_MIN", "T_DAILY_MEAN", "T_DAILY_AVG", "P_DAILY_CALC", "SOLARAD_DAILY",
                        "STATION_NAME", "STATE", "longitude", "latitude")

climate_data <- climate_data[, c("WBANNO", "STATE", "STATION_NAME", "LST_DATE", "CRX_VN",
                         "LONGITUDE", "LATITUDE", "T_DAILY_MAX", "T_DAILY_MIN",
                         "T_DAILY_MEAN", "T_DAILY_AVG", "P_DAILY_CALC", "SOLARAD_DAILY")]

# remove AK_Huslia_27_W from the dataset
climate_data <- climate_data[climate_data$LONGITUDE != -155.47, ]

climate_data[climate_data == -9999.0] <- NA
climate_data[climate_data == -99.000] <- NA
climate_data$LST_DATE <- as.Date(as.character(climate_data$LST_DATE), "%Y%m%d")

save(climate_data, file = "~/Downloads/climateUSA/data/climate_data.RData")
tools::resaveRdaFiles("~/Downloads/climateUSA/data/climate_data.RData", compress = "xz")

