######################################################################################################################

#STEP #1:Install Require Packages and Set directory to load files easily

######################################################################################################################

library(tidyverse) #helps wrangle data
library(lubridate) #helps wrangle data attributes
library(ggplot2) #helps to visualize data
#Displays Current working directory(folder)
getwd()

#Set the working directory to make calls
setwd("/Users/k/Documents") 

######################################################################################################################

#STEP #2: Import the data

######################################################################################################################
m5_2021 <- read_csv("202105-divvy-tripdata.csv")
m6_2021 <- read_csv("202106-divvy-tripdata.csv")
m7_2021 <- read_csv("202107-divvy-tripdata.csv")
m8_2021 <- read_csv("202108-divvy-tripdata.csv")
m9_2021 <- read_csv("202109-divvy-tripdata.csv")
m10_2021 <- read_csv("202110-divvy-tripdata.csv")
m11_2021 <- read_csv("202111-divvy-tripdata.csv")
m12_2021 <- read_csv("202112-divvy-tripdata.csv")
m4_2021 <- read_csv("202104-divvy-tripdata.csv")
m1_2022 <- read_csv("202201-divvy-tripdata.csv")
m2_2022 <- read_csv("202202-divvy-tripdata.csv")
m3_2022 <- read_csv("202203-divvy-tripdata.csv")
######################################################################################################################

# STEP-3: (Clean Data) Drop columns I will not use during this analysis, dropped due to slow laptop processing power

######################################################################################################################

m4_2021 <- m4_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m3_2022 <- m3_2022 %>% select(-c(start_station_id, end_station_name, end_station_id))
m2_2022 <- m2_2022 %>% select(-c(start_station_id, end_station_name, end_station_id))
m1_2022 <- m1_2022 %>% select(-c(start_station_id, end_station_name, end_station_id))
m12_2021 <- m12_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m11_2021 <- m11_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m10_2021 <- m10_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m9_2021 <- m9_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m8_2021 <- m8_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m7_2021 <- m7_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m6_2021 <- m6_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))
m5_2021 <- m5_2021 %>% select(-c(start_station_id, end_station_name, end_station_id))

######################################################################################################################

# STEP-4: Modify and process data for analysis, add new columns to tobels (Day of Week and Ride Length in Secs & Mins)

######################################################################################################################

#Combine tables to create a draft master table. 
total_trips <- bind_rows(m5_2021,m6_2021, m7_2021, m8_2021, m9_2021, m10_2021, m11_2021, m12_2021, m1_2022, m2_2022, m3_2022, m4_2021)

#Results in either "member" or "casual" 
table(total_trips$member_casual) 

#Results in either "classic_bike", "docked_bike", or "electric_bike"
table(total_trips$rideable_type) 

#Add data
total_trips$date <- as.Date(total_trips$started_at)#add a date started column
total_trips$month <- format(as.Date(total_trips$date), "%m")#add a month column
total_trips$day <- format(as.Date(total_trips$date), "%d")#add a day column
total_trips$year <- format(as.Date(total_trips$date), "%Y")#add a year column
total_trips$day_of_week <- format(as.Date(total_trips$date), "%A")#add a day of week column
total_trips$time <- format(total_trips$started_at, format = "%H:%M")  #add a time started column
total_trips$time <- as.POSIXct(total_trips$time, format = "%H:%M")  #change time format for the time column to hour/mins

#Create column ride_length calculating the total time elasped per trip
total_trips$ride_length <- difftime(total_trips$ended_at, total_trips$started_at)
total_trips$ride_length_mins <- difftime(total_trips$ended_at, total_trips$started_at)/60


#Change ride length to a numeric value
total_trips$ride_length <- as.numeric(total_trips$ride_length)
total_trips$ride_length_mins <- as.duration(total_trips$ride_length_mins, 'minutes')

######################################################################################################################

# STEP-6: Further Clean Data for analysis

######################################################################################################################
#Put data in order

total_trips$day_of_week <- ordered(total_trips$day_of_week, levels=c("Monday", "Tuesday", "Wednesday", "Thursday", 
                                                           "Friday", "Saturday", "Sunday"))

#Remove docked bikes from total_trips table bc docked bikes are bikes are not used and could cause inaccuracies
#during analysis.  In addition remove rides that came up with negative values for time.
total_trips_v2 <- total_trips[!(total_trips$rideable_type == "docked_bike" | total_trips$ride_length<0),]

#Remove rides that were to long - rides will be limited to 1 day or 1440 minutes
data.frame(total_trips_v2 <- total_trips_v2[!total_trips_v2$ride_length>1440,] )

#Remove any missing, Null, & N/A data from dataset
drop_na(total_trips_v2)


#Remove any duplicates
data.frame(total_trip_v3<- distinct(total_trips_v2))

drop_na(total_trip_v3)

remove_empty(total_trip_v3)

remove_missing(total_trip_v3)
