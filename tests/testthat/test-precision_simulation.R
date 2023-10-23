test_that("simulation works", {
  buff <- public_land_shape("Mount Buffalo National Park")
  roads <- intersecting_roads(buff)
  road_buff <- road_buffer(buff, roads)
  pr_sim <- precision_simulation(sampling_area = road_buff,
                                 survey_area = buff,
                                 n_sites = 10,
                                 species = "Sambar")

  expect_type(pr_sim, "list")

})
