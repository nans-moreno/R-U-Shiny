# =============================================================================
# MODULE COMPARATEUR
# =============================================================================

fluidRow(
  box(
    title = tags$span(icon("balance-scale"), " Comparateur d'Aliments"),
    status = "primary", 
    solidHeader = TRUE,
    width = 12,

    # Ajout d'une zone de texte pour la recherche personnalisée
    fluidRow(
      column(12,
        textInput("food_search", "Recherche rapide d'aliment :", placeholder = "Tapez un nom d'aliment")
      )
    ),

    fluidRow(
      column(6,
        selectizeInput("food1", 
                      tags$span(icon("apple-alt"), " Sélectionner le 1er aliment:"),
                      choices = NULL,
                      options = list(
                        placeholder = "Tapez pour rechercher...",
                        maxOptions = 1000
                      ))
      ),
      column(6,
        selectizeInput("food2", 
                      tags$span(icon("carrot"), " Sélectionner le 2ème aliment:"),
                      choices = NULL,
                      options = list(
                        placeholder = "Tapez pour rechercher...",
                        maxOptions = 1000
                      ))
      )
    ),
    
    br(),
    div(style = "height: 500px;",
        plotlyOutput("comparison_radar", height = "100%")
    ),
    
    br(),
    div(class = "alert alert-info",
        icon("info-circle"),
        " Sélectionnez deux aliments différents pour voir leur comparaison nutritionnelle sous forme de graphique radar."
    )
  )
)
