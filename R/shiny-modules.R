info_text <- "As a potentially useful resource.We have published a small accompanying web app to conduct simulations of sampling sites using camera trap distance sampling deployments in Victoria (https://justincally.shinyapps.io/deersim/). This app allows for:
        1. Selection of an area (custom) or predefined public land parcel to conduct surveys (e.g. Alpine National Park)
        2. Selection of how many sites to sample and for how many weeks cameras should be deployed
        3. Whether to restrict sampling to be a set distance from the road/track network.
        4. Which species to estimate abundance for.

        The output of the simulation then provides (i) a downloadable shapefile of the proposed sampling locations and (ii) a figure that shows the estimated precision (coefficient of variation) of the estimate and the range of deer abundance that would be expected to reside within the sampling area. The underlying R code used to simulate sampling and build the shiny app available here: https://github.com/JustinCally/deersim."
#' Shiny Map UI for Projects
#'
#' @description Shiny module creating an interactive project map
#'
#' @param id module id
#' @param label module label
#' @param custom_css_path custom css path for map
#' @param custom_js_path custom javascript path for module
#' @param plm_labels plm_labels
#'
#' @return shiny module
#' @export
SimUI <- function(id,
                  label = "Simulation",
                  custom_css_path = system.file("app/styles.css", package = "deersim"),
                  custom_js_path = system.file("app/gomap.js", package = "deersim"),
                  plm_labels = deersim::plm_labels) {

  ns <- shiny::NS(id)
  shiny::tabPanel("Simulate Site Selection",
                  shiny::div(class="outer",

                             shiny::tags$head(
                               # Include our custom CSS
                               shiny::includeCSS(custom_css_path),
                               shiny::includeScript(custom_js_path)
                             ),

                             # If not using custom CSS, set height of leafletOutput to a number instead of percent
                             leaflet::leafletOutput(outputId = ns("map"), width="100%", height="100%"),

                             # Shiny versions prior to 0.11 should use class = "modal" instead.
                             shiny::absolutePanel(id = ns("controls"), class = "panel panel-default", fixed = TRUE,
                                                  draggable = FALSE, top = "auto", left = 20, right = "auto", bottom = 20,
                                                  width = 330, height = "auto",

                                                  shiny::h2("Sample Sites"),
                                                  shinyWidgets::pickerInput(ns("area"), "Study Area",
                                                                            choices = plm_labels,
                                                                            selected = NULL,
                                                                            multiple = TRUE,
                                                                            options = shinyWidgets::pickerOptions(
                                                                              liveSearch = TRUE,
                                                                              liveSearchNormalize = TRUE,
                                                                              size = 10)),
                                                  shiny::conditionalPanel("input.area.length == 0",
                                                                          ns = ns,
                                                  shiny::fileInput(ns("shapefile"), "Import GeoJSON", accept = c(".geojson"))),
                                                  shinyWidgets::materialSwitch(
                                                    inputId = ns("roads"),
                                                    label = "Filter samples to be nearby tracks/roads",
                                                    value = TRUE,
                                                    status = "primary"
                                                  ),
                                                  shiny::conditionalPanel("input.roads == true",
                                                                          ns = ns,
                                                  shiny::sliderInput(
                                                    inputId = ns("roadrange"),
                                                    label = "Choose a range from road:",
                                                    min = 0,
                                                    max = 1000,
                                                    value = c(50, 250))),
                                                  shiny::numericInput(ns("weeks"), "Deployment weeks:",
                                                                      10, min = 1, max = 27),
                                                  shiny::numericInput(ns("sites"), "Number of sites:",
                                                                      40, min = 10, max = 1000),
                                                  shinyWidgets::pickerInput(ns("species"), "Species",
                                                                            choices = c("Sambar", "Fallow", "Red", "Hog"),
                                                                            selected = NULL,
                                                                            multiple = FALSE),
                                                  shiny::actionButton(ns("runsim"),
                                                                      label = "Run Simulation"),
                                                  shinyWidgets::downloadBttn(
                                                    outputId = ns("downloadData"),
                                                    style = "bordered",
                                                    size = "sm",
                                                    color = "primary")
                             ),
                             shiny::conditionalPanel("input.runsim > 0",
                                                     ns = ns,
                                                     shiny::absolutePanel(id = ns("controls"), class = "panel panel-default", fixed = TRUE,
                                                                          draggable = FALSE, top = "auto", left = "auto", right = 20, bottom = 20,
                                                                          width = 400, height = "auto",
                                                                          shiny::plotOutput(ns("variation"))))
                  )
  )
}

#' @describeIn SimUI
#'
#'
#' @return shiny module
#' @export
SimServer <- function(id) {

  shiny::moduleServer(
    id,
    function(input, output, session) {

      shinyalert::shinyalert(
        title = "Information",
        text = info_text,
        size = "s",
        closeOnEsc = TRUE,
        closeOnClickOutside = FALSE,
        html = FALSE,
        type = "info",
        showConfirmButton = TRUE,
        showCancelButton = FALSE,
        confirmButtonText = "OK",
        confirmButtonCol = "#AEDEF4",
        timer = 0,
        imageUrl = "",
        animation = TRUE
      )


      output$map <- leaflet::renderLeaflet({
        leaflet::leaflet() %>%
          leaflet::setView(lng = 145, lat = -37, zoom = 6) %>%
          leaflet::addTiles()
      })

      shiny::observeEvent(input$runsim, {
        shinycssloaders::showPageSpinner(background = "#FFFFFFD0", type = 6, caption = "Processing")
        if(!all(is.null(input$shapefile))) {
          area_shape <- sf::st_read(input$shapefile$datapath)
        } else {
        area_shape <- public_land_shape(input$area)
        }
        if(input$roads) {
        road_shape <- intersecting_roads(shape = area_shape, buffer = max(input$roadrange))
        sampling_shape <- road_buffer(area = area_shape,
                                  roads = road_shape,
                                  min_distance = min(input$roadrange),
                                  max_distance = max(input$roadrange))
        } else {
          sampling_shape <- area_shape
        }

        sample_data <- precision_simulation(deployment_weeks = input$weeks,
                                            sampling_area = sampling_shape,
                                            survey_area = area_shape,
                                            n_sites = input$sites,
                                            species = input$species)

        shinycssloaders::hidePageSpinner()

        leaflet::leafletProxy("map") %>%
          leaflet::clearMarkers() %>%
          leaflet::removeControl("legend") %>%
          leaflet::clearShapes() %>%
          leaflet::setView(lng = 145, lat = -37, zoom = 6) %>%
          leaflet::addCircleMarkers(data = sample_data[["sampling_locations"]],
                                    fillOpacity=0.6,
                                    fillColor="Red",
                                    weight = 2,
                                    color = "black")

        output$variation <- shiny::renderPlot({
          df <- data.frame(Estimates = sample_data[["abundance_estimates"]])
          ggplot2::ggplot() +
            ggplot2::geom_histogram(data = df, ggplot2::aes(x = .data[["Estimates"]]), fill = "grey30") +
            ggplot2::geom_vline(xintercept = sample_data[["abundance_true"]],
                                linetype = "dashed", colour = "darkred", linewidth = 1.5) +
            ggplot2::ggtitle("Range of expected abundance \nestimates for the area",
                             subtitle = paste0("CV = ", round(sample_data[["CV"]], 2), "\n",
                                              "90 % CI = ",
                                              round(stats::quantile(sample_data[["abundance_estimates"]], 0.05)),
                                              " - ",
                                              round(stats::quantile(sample_data[["abundance_estimates"]], 0.95)))) +
            ggplot2::xlab("Simulated vs True Abundance") +
            ggplot2::theme_bw()
        })

        # Download data

        output$downloadData <- shiny::downloadHandler(
          filename <- function() {
            "Sampling_Locations.zip"

          },
          content = function(file) {

              tmp.path <- dirname(file)

              name.base <- file.path(tmp.path, "DeerSamplingLocations")
              name.glob <- paste0(name.base, ".*")
              name.shp  <- paste0(name.base, ".shp")
              name.zip  <- paste0(name.base, ".zip")

              if (length(Sys.glob(name.glob)) > 0) file.remove(Sys.glob(name.glob))
              sf::st_write(sample_data[["sampling_locations"]], dsn = name.shp, ## layer = "shpExport",
                           driver = "ESRI Shapefile", quiet = TRUE)

              zip::zipr(zipfile = name.zip, files = Sys.glob(name.glob))
              shiny::req(file.copy(name.zip, file))

              if (length(Sys.glob(name.glob)) > 0) file.remove(Sys.glob(name.glob))
          }
        )

      })}

  )
}

