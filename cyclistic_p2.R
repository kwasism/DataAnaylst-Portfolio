library(tidyverse) 
library(dplyr)
library(ggplot2)

######################################################################################################################

# STEP-6: Analysis

######################################################################################################################
#Count the total number of casual and member riders
table(total_trip_v3$member_casual)

#Average ride of memebr type in Minutes
total_trip_v3 %>% 
  group_by(member_casual) %>% 
  summarise(total_rides = n() ,average_duration_mins = mean(ride_length_mins)) 

#Average ride of member type in Seconds
total_trip_v3 %>% 
  group_by(member_casual) %>% 
  summarise(total_rides = n() ,average_duration = mean(ride_length)) 

#Ride types used by member type
total_trip_v3 %>% 
  group_by(member_casual, rideable_type) %>% 
  summarise(num.rideable_type = n())

#Days of the week bikes are used by member type
total_trip_v3 %>% 
  arrange(desc(member_casual), decreasing= FALSE) %>% 
  group_by(member_casual,day_of_week) %>%
  summarise(total_riders = n())


#Create table for analysis of top 10 starting stations, put the results for the number of trips 
#to each station by member type
start_stations<-total_trip_v3 %>%
    group_by(member_casual,start_station_name) %>% 
    summarise(total = n()) %>% 
    arrange(desc(total), decreasing= TRUE) %>% 
    drop_na() %>% 
    slice(1:20)

#Check if table works for analysis
view(start_stations)

#Top 10 Starting Stations for Casual Riders
start_stations1 <- filter(start_stations, member_casual=='casual') %>% 
  arrange(desc(total)) %>% 
  slice (1:10)
#Top 10 Starting Stations for Memeber Riders
start_stations2 <- filter(start_stations, member_casual=='member') %>% 
  arrange(desc(total)) %>% 
  slice (1:10)

#Combine the data of the two created filtered tables for later analysis using a union
start_stations_v2 <- union_all(start_stations1,start_stations2)

#Check to see if union of table data was successful
print(start_stations_v2)

#Looking at demand for bikes over a 24 hour period, per hour, by member type 
total_trip_v3%>%     
  group_by(member_casual, time) %>% 
  summarise(total_rides = n()) 
######################################################################################################################

# STEP-7: Create Visual Graphics for Analysis

######################################################################################################################
#Average ride of memebr type in Seconds

total_trip_v3 %>% 
  group_by(member_casual) %>% 
  summarise(total_rides = n() ,average_duration_secs = mean(ride_length)) %>% 
  ggplot(aes(x=average_duration_secs, y = format(total_rides, scientific = FALSE), fill = member_casual))+ 
  geom_col(position = "dodge") +
  labs (x="Average Ride Length(Secs)", y = "Total Number of Rides", title = "Average Ride Length by Customer Type", 
        subtitle = "April 2021 - March 2022", fill = "Membership Type") + 
  theme(axis.text.x = element_text(angle = 0))



#Average ride of memebr type in Minutes

total_trip_v3 %>% 
  group_by(member_casual) %>% 
  summarise(total_rides = n() ,average_duration_mins = mean(ride_length_mins)) %>% 
ggplot(aes(x=average_duration_mins, y = format(total_rides, scientific = FALSE), fill = member_casual))+ 
  geom_col(position = "dodge") +
  labs (x="Average Ride Length(min)", y = "Total Number of Rides", title = "Average Ride Length by Customer Type", 
        subtitle = "April 2021 - March 2022", fill = "Membership Type") + 
        theme(axis.text.x = element_text(angle = 0))



#Number of Rides by Days of the week bikes are used by member type

total_trip_v3 %>% 
  group_by(member_casual,day_of_week) %>%
  summarise(total_riders = n())%>% 
ggplot(aes(x=day_of_week, y = format(total_riders, scientific = FALSE), fill = member_casual))+
  geom_col(position = "dodge") + labs (x="Day of Week", y="Total Number of Riders", 
                                       title = "Average Ride Length by Customer Type and Day of Week",
                                       subtitle = "April 2021 - March 2022", fill = "Membership Type") 



#Top 10 Starting Stations for Casual Riders
ggplot(data = start_stations1, aes(x = start_station_name, y = total, fill = member_casual)) + 
  geom_col(position = "dodge")+
  theme(axis.text.x = element_text(angle = 285))+ 
  labs(x= 'Starting Station Name', y='Total Number of Riders', title='Top 10 Starting Stations for Casual Riders', 
       subtitle = "April 2021 - March 2022", fill = 'Membership Type')



#Top 10 Starting Stations for Memeber Riders
ggplot(data = start_stations2, aes(x = start_station_name, y = total, fill = member_casual))+
  geom_col(position = "dodge")+
  theme(axis.text.x = element_text(angle = 285))+ 
  labs(x= 'Starting Station Name', y='Total Number of Riders', title='Top 10 Starting Stations for Memeber Riders', 
       subtitle = "April 2021 - March 2022", fill = 'Membership Type')



#Top 10 Starting Stations for Memeber vs. Casual Riders
ggplot(data = start_stations_v2, aes(x = start_station_name, y= total, fill = member_casual)) + 
  geom_col(position = "dodge")+
  theme(axis.text.x = element_text(angle = 300))+ 
  labs(x= 'Starting Station Name', y='Total Number of Riders', title='Top 10 Starting Stations for Memeber vs. Casual Riders', 
       subtitle = "April 2021 - March 2022", fill = 'Membership Type')
 
  

#Create Bar Chart for Type of Bikes Rented by Member Type
ggplot(data = total_trip_v3, aes(x = rideable_type, fill = member_casual)) + 
  geom_bar(position = "dodge") + 
  labs(x= 'Bike Types', y='Number of Rentals', title='Rider Type Bike Type Usage', 
  subtitle = "April 2021 - March 2022", fill = 'Membership Type')



#Create Line Graph Looking at demand for bikes over a 24 hour period, per hour, by member type,
total_trip_v3%>%     
  group_by(member_casual, time) %>% 
  summarise(total_rides = n()) %>% 
ggplot(aes(x=time, y=total_rides, color = member_casual, group = member_casual)) +
  geom_line() + scale_x_datetime(date_breaks = "1 hour", date_labels = "%H:%M", expand = c(0,0)) +
  theme(axis.text.x = element_text(angle = 300)) + 
  labs(title ="Demand Throughout the Day", subtitle = "April 2021 - March 2022", 
  x = "Time", y = "Total Number of Rides")
  

######################################################################################################################

# STEP-8: Save Charts and Tables Created to System

######################################################################################################################

#Save Tables to System
write.csv(start_stations,"/Users/k/Documents/cyclistic_start_stations.csv", row.names = FALSE)
write.csv(total_trip_v3,"/Users/k/Documents/cyclistic_total_trip_v3.csv", row.names = FALSE)
write.csv(total_trips_v2,"/Users/k/Documents/cyclistic_total_trips_v2.csv", row.names = FALSE)
write.csv(total_trips,"/Users/k/Documents/cyclistic_total_trips.csv", row.names = FALSE)

