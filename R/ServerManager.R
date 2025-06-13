library(tibble)
# =============================================================================
# SERVER MANAGER - Classe pour la logique serveur
# =============================================================================

ServerManager <- R6Class(
  "ServerManager",
  
  # === PROPRIÉTÉS PRIVÉES ===
  private = list(
    .data_manager = NULL,
    .server_function = NULL
  ),
  
  # === PROPRIÉTÉS PUBLIQUES ===
  public = list(
    
    #' Initialisation
    #' @param data_manager Instance de DataManager
    initialize = function(data_manager) {
      private$.data_manager <- data_manager
      cat("⚙️ ServerManager initialisé\n")
    },
    
    #' Données réactives filtrées
    create_filtered_data = function(input, output, session) {
      reactive({
        private$.data_manager$filter_data(
          category = input$category,
          calorie_range = input$calories_range,
          protein_range = input$protein_range,
          search_term = input$search
        )
      })
    },
    
    #' Gestion du reset des filtres
    handle_reset_filters = function(input, output, session) {
      observeEvent(input$reset_filters, {
        updateSelectInput(session, "category", selected = "all")
        updateSliderInput(session, "calories_range", value = c(0, 500))
        updateSliderInput(session, "protein_range", value = c(0, 50))
        updateTextInput(session, "search", value = "")
        
        showNotification("🔄 Filtres réinitialisés", type = "message")
      })
    },
    
    #' Métriques (Value Boxes)
    create_value_boxes = function(filtered_data, output) {
      
      output$total_foods <- renderValueBox({
        valueBox(
          value = nrow(filtered_data()),
          subtitle = "Aliments",
          icon = icon("utensils"),
          color = "blue"
        )
      })
      
      output$avg_calories <- renderValueBox({
        valueBox(
          value = round(mean(filtered_data()$Calories, na.rm = TRUE)),
          subtitle = "Calories Moyennes",
          icon = icon("fire"),
          color = "orange"
        )
      })
      
      output$max_protein <- renderValueBox({
        valueBox(
          value = paste0(round(max(filtered_data()$Protein_g, na.rm = TRUE)), "g"),
          subtitle = "Protéines Max",
          icon = icon("dumbbell"),
          color = "green"
        )
      })
    },
    
    #' Graphiques de la vue d'ensemble
    create_overview_plots = function(filtered_data, output, input) {
      
      # Distribution des calories
      output$calorie_dist <- renderPlotly({
        p <- filtered_data() %>%
          ggplot(aes(x = Calories)) +
          geom_histogram(bins = 30, fill = "steelblue", alpha = 0.7, color = "white") +
          labs(title = "Distribution des Calories",
               x = "Calories (kcal)", 
               y = "Nombre d'aliments") +
          theme_minimal() +
          theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))
        
        ggplotly(p) %>%
          layout(title = list(font = list(size = 16)))
      })
      
      # Graphique en secteurs par catégorie
      output$category_pie <- renderPlotly({
        category_counts <- filtered_data() %>%
          count(Food_Category) %>%
          arrange(desc(n))
        
        plot_ly(
          category_counts, 
          labels = ~Food_Category, 
          values = ~n, 
          type = 'pie',
          textposition = 'inside',
          textinfo = 'label+percent',
          marker = list(colors = get_color_palette(nrow(category_counts)))
        ) %>%
          layout(
            title = list(text = "Répartition par Catégorie", font = list(size = 16)),
            showlegend = TRUE
          )
      })
      
      # Top 10 des aliments les plus caloriques
      output$top_calories_table <- DT::renderDataTable({
        filtered_data() %>%
          arrange(desc(Calories)) %>%
          head(10) %>%
          select(Food_Name, Calories, Protein_g, Fat_g, Food_Category) %>%
          DT::datatable(
            options = list(
              pageLength = 10, 
              scrollX = TRUE,
              dom = 't'
            ),
            rownames = FALSE,
            colnames = c("Aliment", "Calories", "Protéines (g)", "Lipides (g)", "Catégorie")
          ) %>%
          DT::formatRound(columns = c("Calories", "Protein_g", "Fat_g"), digits = 1)
      })
      
      # Tableau complet avec sélection de colonnes
      output$overview_full_table <- DT::renderDataTable({
        data <- private$.data_manager$get_clean_data()
        cols <- input$overview_columns_to_show
        if (is.null(cols) || length(cols) == 0) {
          cols <- names(data)
        }
        data <- data[, cols, drop = FALSE]
        DT::datatable(
          data,
          options = list(
            pageLength = 15,
            scrollX = TRUE,
            searching = TRUE
          ),
          filter = 'top',
          rownames = FALSE
        )
      })
    },
    
    #' Graphiques de l'analyse détaillée
    create_analysis_plots = function(filtered_data, output, input) {
      
      # Corrélation Protéines vs Calories
      output$protein_calories_scatter <- renderPlotly({
        p <- filtered_data() %>%
          ggplot(aes(x = Protein_g, y = Calories, 
                     color = Food_Category, 
                     text = paste("Aliment:", Food_Name,
                                  "<br>Protéines:", Protein_g, "g",
                                  "<br>Calories:", Calories, "kcal"))) +
          geom_point(alpha = 0.7, size = 2) +
          scale_color_manual(values = get_color_palette(length(unique(filtered_data()$Food_Category)))) +
          labs(title = "Relation Protéines vs Calories",
               x = "Protéines (g)", 
               y = "Calories (kcal)",
               color = "Catégorie") +
          theme_minimal() +
          theme(plot.title = element_text(hjust = 0.5, size = 14, face = "bold"))
        
        ggplotly(p, tooltip = "text") %>%
          layout(title = list(font = list(size = 16)))
      })
      
      # Statistiques résumées
      output$summary_stats <- renderTable({
        filtered_data() %>%
          summarise(
            `Nombre d'aliments` = n(),
            `Calories moyennes` = round(mean(Calories, na.rm = TRUE), 1),
            `Protéines moyennes` = round(mean(Protein_g, na.rm = TRUE), 1),
            `Lipides moyens` = round(mean(Fat_g, na.rm = TRUE), 1),
            `Glucides moyens` = round(mean(Carbs_g, na.rm = TRUE), 1)
          ) %>%
          pivot_longer(everything(), names_to = "Métrique", values_to = "Valeur")
      }, striped = TRUE, hover = TRUE)
      
      # Tableau filtré
      output$filtered_table <- DT::renderDataTable({
        data <- filtered_data()
        cols <- input$columns_to_show
        if (is.null(cols) || length(cols) == 0) {
          cols <- names(data) # Affiche tout si rien sélectionné
        }
        data <- data[, cols, drop = FALSE]
        DT::datatable(
          data,
          options = list(
            pageLength = 15, 
            scrollX = TRUE,
            searching = TRUE,
            placeholder = "Tapez pour rechercher...",
            maxOptions = 100
          ),
          filter = 'top',
          rownames = FALSE
        )
      })
    },
    
    #' Fonctionnalité comparateur
    create_comparison_functionality = function(filtered_data, input, output, session) {
      
      # Mise à jour des choix dans le comparateur
       observe({
  all_foods <- private$.data_manager$get_clean_data()
  # Force Food_ID en caractère pour éviter les soucis de recherche
  food_choices <- setNames(as.character(all_foods$Food_ID), all_foods$Food_Name)

  updateSelectizeInput(session, "food1", 
                      choices = food_choices, 
                      server = TRUE)
  updateSelectizeInput(session, "food2", 
                      choices = food_choices, 
                      server = TRUE)
})
      
      # Graphique radar de comparaison
      output$comparison_radar <- renderPlotly({
        if(!is.null(input$food1) && !is.null(input$food2) && 
           input$food1 != input$food2) {
          
          all_data <- private$.data_manager$get_clean_data()
          food1_data <- all_data %>% filter(Food_ID == input$food1)
          food2_data <- all_data %>% filter(Food_ID == input$food2)
          
          if(nrow(food1_data) > 0 && nrow(food2_data) > 0) {
            
            # Préparation des données pour le radar
            comparison_data <- data.frame(
              Metric = c("Calories (/10)", "Protéines", "Lipides", "Glucides", "Fibres"),
              Food1 = c(
                round(food1_data$Calories / 10, 1),
                round(food1_data$Protein_g, 1),
                round(food1_data$Fat_g, 1),
                round(food1_data$Carbs_g, 1),
                round(coalesce(food1_data$Fiber_g, 0), 1)
              ),
              Food2 = c(
                round(food2_data$Calories / 10, 1),
                round(food2_data$Protein_g, 1),
                round(food2_data$Fat_g, 1),
                round(food2_data$Carbs_g, 1),
                round(coalesce(food2_data$Fiber_g, 0), 1)
              )
            )
            
            plot_ly(
              type = 'scatterpolar',
              mode = 'lines+markers'
            ) %>%
              add_trace(
                r = comparison_data$Food1,
                theta = comparison_data$Metric,
                name = food1_data$Food_Name,
                line = list(color = '#1f77b4', width = 3),
                marker = list(size = 8)
              ) %>%
              add_trace(
                r = comparison_data$Food2,
                theta = comparison_data$Metric,
                name = food2_data$Food_Name,
                line = list(color = '#ff7f0e', width = 3),
                marker = list(size = 8)
              ) %>%
              layout(
                polar = list(
                  radialaxis = list(
                    visible = TRUE, 
                    range = c(0, max(c(comparison_data$Food1, comparison_data$Food2)) * 1.1)
                  )
                ),
                title = list(text = "Comparaison Nutritionnelle", font = list(size = 16)),
                legend = list(orientation = "h", x = 0.5, xanchor = 'center')
              )
          }
        }
      })
    },
    
    #' Fonction serveur principale
    create_server = function() {
      function(input, output, session) {
        
        # Données réactives
        filtered_data <- self$create_filtered_data(input, output, session)
        
        # Gestion du reset
        self$handle_reset_filters(input, output, session)
        
        # Métriques
        self$create_value_boxes(filtered_data, output)
        
        # Graphiques vue d'ensemble
       self$create_overview_plots(filtered_data, output, input)
        
        # Graphiques analyse détaillée
        self$create_analysis_plots(filtered_data, output, input)
        
        # Comparateur
        self$create_comparison_functionality(filtered_data, input, output, session)
        
        # Message de bienvenue
        showNotification(
          "🎉 Dashboard nutritionnel chargé avec succès!", 
          type = "message",
          duration = 3
        )
      }
    }
  )
)

cat("✅ Classe ServerManager créée\n")
