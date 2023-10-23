buff <- deersim:::public_land_shape("Mount Buffalo National Park")
roads <- deersim:::intersecting_roads(buff)
test_that("plm shape works", {
  expect_s3_class(buff, "sf")
})

test_that("road shape works", {
  expect_s3_class(roads, "sf")
})

test_that("overlapping area and road shape works", {
  road_buff <- deersim:::road_buffer(buff, roads)
  expect_s3_class(road_buff, "sfc_MULTIPOLYGON")
})
