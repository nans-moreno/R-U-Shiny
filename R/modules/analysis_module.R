# =============================================================================
# MODULE ANALYSE DÉTAILLÉE
# =============================================================================

fluidRow(
  box(
    title = tags$span(icon("scatter-chart"), " Corrélation Protéines vs Calories"),
    status = "primary", 
    solidHeader = TRUE,
    width = 8,
    height = 500,
    plotlyOutput("protein_calories_scatter")
  ),
  box(
    title = tags$span(icon("table"), " Statistiques Résumées"),
    status = "info", 
    solidHeader = TRUE,
    width = 4,
    height = 500,
    tableOutput("summary_stats")
  )
),

fluidRow(
  box(
    title = tags$span(icon("list"), " Tableau des Aliments Filtrés"),
    status = "success", 
    solidHeader = TRUE,
    width = 12,
    DT::dataTableOutput("filtered_table")
  )
)
