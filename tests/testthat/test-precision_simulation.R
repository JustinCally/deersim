test_that("simulation works", {
  pr_sim <- precision_simulation(sampling_area = road_buff,
                                 survey_area = buff,
                                 n_sites = 100,
                                 species = "Sambar")
})
