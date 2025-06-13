# =============================================================================
# MODULE ANALYSE DÉTAILLÉE
# =============================================================================

fluidRow(
  box(
   title = tags$span(icon("chart-bar"), " Corrélation Protéines vs Calories"),
    status = "primary", 
    solidHeader = TRUE,
    width = 8,
    height = 500,
    plotlyOutput("protein_calories_scatter")
  ), # <-- Virgule ici, parenthèse bien placée
  box(
    title = tags$span(icon("table"), " Statistiques Résumées"),
    status = "info",
    solidHeader = TRUE,
    width = 4,
    height = 500,
    tableOutput("summary_stats")
  )
)

fluidRow(
  box(
    title = tags$span(icon("list"), " Tableau des Aliments Filtrés"),
    status = "success", 
    solidHeader = TRUE,
    width = 12,
    # Sélecteur de colonnes à afficher
    shinyWidgets::pickerInput(
      inputId = "columns_to_show",
      label = "Colonnes à afficher :",
      choices = c("Food_Name", "Calories", "Protein_g", "Fat_g", "Carbs_g", "Fiber_g", "Sugar_g", "Calcium_mg", "Iron_mg", "VitC_mg", "Food_Category", "Calorie_Level", "Protein_Ratio", "Fat_Ratio", "Carbs_Ratio"),
      selected = c("Food_Name", "Calories", "Protein_g", "Fat_g", "Carbs_g", "Food_Category"),
      multiple = TRUE,
      options = shinyWidgets::pickerOptions(actionsBox = TRUE, liveSearch = TRUE)
    ),
    DT::dataTableOutput("filtered_table")
  )
)
