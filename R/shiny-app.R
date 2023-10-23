#' Run site simulation app
#'
#' @return shiny app
#' @export
#'
#' @examples
#' \dontrun{
#' simulation_app()
#' }
simulation_app <- function() {
  # Setup load packages
  options(shiny.maxRequestSize = 30*1024^2)

  # Define UI for data upload app ----
  ui <- shiny::navbarPage("Victorian Deer Monitoring", id="nav",
                          deersim::SimUI(id = "map", label = "Simulation")
  )

  # Define server logic to read selected file ----
  server <- function(input, output) {
    deersim::SimServer(id = "map")
  }
  # Run the app ----
  shiny::shinyApp(ui, server)
}
