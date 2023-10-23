public_land_shape <- function(park_label) {
  pl_select <- VicmapR::vicmap_query("open-data-platform:plm25") %>%
  VicmapR::filter(label %in% !!park_label) %>%
  VicmapR::collect(quiet = TRUE)

  return(pl_select)
}

intersecting_roads <- function(shape, buffer = 250) {

  shape_buffer <- shape %>% sf::st_transform(3111) %>% sf::st_buffer(buffer)

  road_select <- VicmapR::vicmap_query("open-data-platform:tr_road") %>%
    VicmapR::filter(VicmapR::INTERSECTS(shape_buffer)) %>%
    VicmapR::collect(quiet = TRUE)

  return(road_select)
}

road_buffer <- function(area,
                        roads,
                        min_distance = 50,
                        max_distance = 250) {

  roads_3111 <- roads %>%
    sf::st_transform(3111) %>%
    sf::st_make_valid()

  area_3111 <- area %>%
    sf::st_transform(3111) %>%
    sf::st_make_valid() %>%
    sf::st_combine()

  road_buffer <- sf::st_buffer(roads_3111, dist = max_distance)
  road_remove <- sf::st_buffer(roads_3111, dist = min_distance)

  road_proc <- rmapshaper::ms_erase(road_buffer, erase = road_remove)

  area_proc <- rmapshaper::ms_clip(area_3111,road_proc)

  return(area_proc)
}


