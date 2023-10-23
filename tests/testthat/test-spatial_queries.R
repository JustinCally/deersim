test_that("plm shape works", {
  buff <- public_land_shape("Mount Buffalo National Park")
})

test_that("road shape works", {
  roads <- intersecting_roads(buff)
})

test_that("road shape works", {
  road_buff <- road_buffer(buff, roads)
})
