test_that("simulation works", {
  buff <- deersim:::public_land_shape("Mount Buffalo National Park") %>% sf::st_transform(3111)
  roads <- deersim:::intersecting_roads(buff) %>% sf::st_transform(3111)
  road_buff <- deersim:::road_buffer(buff, roads)
  pr_sim <- deersim:::precision_simulation(sampling_area = road_buff,
                                 survey_area = buff,
                                 n_sites = 10,
                                 species = "Sambar")

  expect_type(pr_sim, "list")

})
