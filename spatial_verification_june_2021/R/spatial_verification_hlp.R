library(tidyverse)
library(sf)
library(butteR)
library(rtree)

# reading data
df_collect_data <- read_csv("inputs/REACH_UGA_HLP_raw_dataset.csv") %>% filter(
  refugee_settlement == "kiryandongo"
)

df_collect_data_pts <- st_as_sf(df_collect_data, coords = c("_geopoint_longitude","_geopoint_latitude"), crs = 4326)
  
  
# st_transform(crs = 32636)


df_limits <- st_read("inputs/Kiyandongo settlements", "Kiryandongo_settlement", quiet=T) %>% st_transform(crs = 4326)
df_sample_pts <- st_read("inputs/Kiryandongo_pts", "Kiryandongo_HLP_pts", quiet=T) %>% st_transform(crs = 4326)


# map of interviews, sample pts and limits
ggplot()+
  geom_sf(data = df_limits)+
  geom_sf(data = df_collect_data_pts)+
  geom_sf(data = df_sample_pts)+
  theme_bw()

# check_point_distance_by_id
?butteR::check_point_distance_by_id()

find_some_dist <- check_point_distance_by_id(sf1=df_collect_data_pts, sf2=df_sample_pts, sf1_id = "point_number", sf2_id = "OBJECTID",dist_threshold = 150 )

my_data <- find_some_dist$dataset
find_some_dist$map
find_some_dist$hist

plot(my_data %>% filter(dist_m > 20) %>% select(point_number))
# # check_distances_from_target
# ?butteR::check_distances_from_target()
# find_some_dist_from_target <- check_distances_from_target(dataset_sf = df_collect_data_pts, target_points = df_sample_pts, cols_to_report = c("uuid", "point_number"), distance_threshold = 150 )
# # Error: 'knn.RTree' is not an exported object from 'namespace:rtree'


# get distances
target_sample_index <-  df_collect_data_pts %>% 
  st_nearest_feature(df_sample_pts)
# find_some_dist <- st_distance(df_collect_data_pts[df_collect_data_pts$point_number == df_sample_pts$OBJECTID,], df_sample_pts, by_element = T)
# testing one single point "22"
find_some_dist <- st_distance(df_collect_data_pts[df_collect_data_pts$point_number == 73,], df_sample_pts[df_sample_pts$OBJECTID == 73,], by_element = T)



# rtree -------------------------------------------------------------------

sample_pts_tree <- RTree(x = st_coordinates(df_sample_pts))

wd_ls <- withinDistance(sample_pts_tree, st_coordinates(df_collect_data_pts), 0.01)
