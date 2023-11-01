# # This is a Shiny web application. You can run the application by clicking
# # the 'Run App' button above.
# #
# # Find out more about building applications with Shiny here:
# #
# #    http://shiny.rstudio.com/
# #
#
# library(shiny)
# library(diagram)
# library(shape)
#
# # Define UI for application that draws a histogram
# ui <- fluidPage(
#   # Show a plot of the generated distribution
#   mainPanel(
#     plotOutput("testplot")
#   )
# )
#
# # Define server logic required to draw a histogram
# server <- function(input, output) {
#   #
#   output$testplot <- renderPlot({
#     par(mar = c(1, 1, 1, 1))
#     openplotmat()
#     elpos <- coordinates (c(1, 1, 2, 4))
#     fromto <- matrix(ncol = 2, byrow = TRUE, data = c(1, 2, 2, 3, 2, 4, 4, 7, 4, 8,3,5,3,6))
#     nr <- nrow(fromto)
#     arrpos <- matrix(ncol = 2, nrow = nr)
#     for (i in 1:nr)
#       arrpos[i, ] <- straightarrow (to = elpos[fromto[i, 2], ],
#                                     from = elpos[fromto[i, 1], ], lwd = 2, arr.pos = 0.6, arr.length = 0.5)
#     textellipse(elpos[1,], 0.1, lab = "start", box.col = "green",
#                 shadow.col = "darkgreen", shadow.size = 0.005, cex = 1.5)
#     textrect (elpos[2,], 0.15, 0.05,lab = "found term?", box.col = "grey",
#               shadow.col = "darkblue", shadow.size = 0.005, cex = 1.5)
#     textrect (elpos[4,], 0.15, 0.05,lab = "related?", box.col = "grey",
#               shadow.col = "darkblue", shadow.size = 0.005, cex = 1.5)
#     textellipse(elpos[3,], 0.1, 0.1, lab = c("other","term"), box.col = "orange",
#                 shadow.col = "red", shadow.size = 0.005, cex = 1.5)
#     textellipse(elpos[7,], 0.1, 0.1, lab = c("make","a link"),box.col = "orange",
#                 shadow.col = "red", shadow.size = 0.005, cex = 1.5)
#     textellipse(elpos[8,], 0.1, 0.1, lab = c("new","article"),box.col = "orange",
#                 shadow.col = "red", shadow.size = 0.005, cex = 1.5)
#     textellipse(elpos[5,], 0.1, 0.1, lab = c("make","a link"),box.col = "orange",
#                 shadow.col = "red", shadow.size = 0.005, cex = 1.5)
#     textellipse(elpos[6,], 0.1, 0.1, lab = c("new","article"),box.col = "orange",
#                 shadow.col = "red", shadow.size = 0.005, cex = 1.5)
#     #
#     dd <- c(0.0, 0.025)
#     text(arrpos[2, 1] + 0.05, arrpos[2, 2], "yes")
#     text(arrpos[3, 1] - 0.05, arrpos[3, 2], "no")
#     text(arrpos[4, 1] + 0.05, arrpos[4, 2] + 0.05, "yes")
#     text(arrpos[5, 1] - 0.05, arrpos[5, 2] + 0.05, "no")
#   })
# }
#
# # Run the application
# shinyApp(ui = ui, server = server)
