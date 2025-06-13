# =============================================================================
# MODULE VUE D'ENSEMBLE
# =============================================================================

fluidRow(
  # Métriques importantes
  valueBoxOutput("total_foods", width = 4),
  valueBoxOutput("avg_calories", width = 4),
  valueBoxOutput("max_protein", width = 4)
)

fluidRow(
  box(
    title = tags$span(icon("chart-bar"), " Distribution des Calories"), 
    status = "primary", 
    solidHeader = TRUE,
    width = 6,
    height = 400,
    plotlyOutput("calorie_dist")
  ),
  box(
    title = tags$span(icon("chart-pie"), " Répartition par Catégorie"), 
    status = "success", 
    solidHeader = TRUE,
    width = 6,
    height = 400,
    plotlyOutput("category_pie")
  )
)

fluidRow(
  box(
    title = tags$span(icon("trophy"), " Top 10 des Aliments les Plus Caloriques"),
    status = "warning", 
    solidHeader = TRUE,
    width = 12,
    DT::dataTableOutput("top_calories_table")
  )
)
