#' Generate a simulation of abundance estimates for selected sites
#'
#' @param deployment_weeks weeks to deploy cameras for
#' @param sampling_area area to sample within (i.e., can be resricted around roads)
#' @param survey_area total area to estimate abundance for (e.g. full National Park)
#' @param n_sites number of camera sites
#' @param species species (Sambar, Fallow, Red and Hog)
#' @param sampling_type type of sampling to use (hexagonal or random)
#'
#' @return list
#' @export
precision_simulation <- function(deployment_weeks = 10,
                                 sampling_area,
                                 survey_area,
                                 n_sites,
                                 species = c("Sambar", "Fallow", "Red", "Hog"),
                                 sampling_type = "hexagonal") {

  # Survey effort: snapshot moments
  dep_times <- lubridate::seconds(lubridate::weeks(deployment_weeks))/2
  survey_effort <- as.numeric(42/360 * dep_times * pi * (12.5/1000)^2)

  # Average detection probability
  det_p <- 0.297

  # Average availability
  availability = stats::rbeta(1, 215, 181)

  survey_area_3111 <- survey_area %>%
    sf::st_transform(3111) %>%
    sf::st_combine()

  survey_area_size <- sf::st_area(survey_area_3111) %>%
    units::set_units("km2")

  species_idx <- switch(species, Sambar = 1, Fallow = 2, Red = 3, Hog = 4)

  sampled_sites <- sf::st_sample(x = sampling_area %>% sf::st_transform(3111),
                                 size = n_sites,
                                 type = sampling_type)

  combined_raster <- terra::rast("https://raw.githubusercontent.com/JustinCally/statewide-deer-analysis/main/outputs/rasters/combined_deer_average_density.tif")
  combined_sd_raster <- terra::rast("https://raw.githubusercontent.com/JustinCally/statewide-deer-analysis/main/outputs/rasters/combined_deer_sd.tif")

  abundance_area <- terra::extract(combined_raster, terra::vect(survey_area_3111), ID = F, na.rm=TRUE)
  abundance_est <- terra::extract(combined_raster, terra::vect(sampled_sites), ID = F, na.rm=TRUE, method = "bilinear")

  sampled_sites <- sampled_sites[which(!is.na(abundance_est[,species_idx]))]

  abundance_est <- abundance_est[which(!is.na(abundance_est[,species_idx])),]

  sd_est <- terra::extract(combined_sd_raster, terra::vect(sampled_sites), ID = F, na.rm=TRUE, method = "bilinear")

  raw_counts <- matrix(nrow = length(sampled_sites), ncol = 1000)
  dens_est <- matrix(nrow = length(sampled_sites), ncol = 1000)

  for(i in 1:length(sampled_sites)) {
    raw_counts[i,] <- stats::rnbinom(1000,mu=abundance_est[i,species_idx]*det_p*availability*survey_effort,size=abundance_est[i,species_idx]^2/((sd_est[i,species_idx]^2)-abundance_est[i,species_idx]))
    dens_est[i,] <- raw_counts[i,] /(det_p*availability*survey_effort)
  }

  dens_mean <- vector()
  ab_mean <- vector()
  for(j in 1:1000) {
    dens_mean[j] <- mean(dens_est[,j])
    ab_mean[j] <- dens_mean[j]*survey_area_size
  }

  # grand_mean <- mean(ab_mean)
  # grand_cv <- sd(ab_mean)/grand_mean

  true_ab <- sum(abundance_area[,species_idx], na.rm = TRUE)

  final_return <- list(abundance_estimates = ab_mean,
                       abundance_true = true_ab,
                       CV = stats::sd(ab_mean)/mean(ab_mean),
                       sampling_locations = dplyr::bind_cols(sf::st_as_sf(sampled_sites), abundance_est) %>%
                         sf::st_set_geometry("geometry") %>%
                         sf::st_transform(7844),
                       deployment_weeks = deployment_weeks,
                       n_sites = length(sampled_sites),
                       species = species,
                       sampling_type = sampling_type,
                       survey_area_size = survey_area_size)

  return(final_return)

}

