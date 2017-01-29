## server.R ##

shinyServer(function(input, output){
  
  output$map1 <- renderLeaflet({
    leaflet(filter_(nyc.collisions, 
                   input$filter, input$borough)%>% 
              filter(DATE > input$dateRange[1] & DATE < input$dateRange[2])) %>% 
      addTiles()%>%
      addWebGLHeatmap(lng=~LONGITUDE, lat=~LATITUDE,size = input$heatslide, 
                      alphaRange = .01, opacity = .45)
    })
  
  output$map2 <- renderLeaflet({
    leaflet() %>%
      addTiles()%>%
      fitBounds(min(collisions.killed$LONGITUDE), min(collisions.killed$LATITUDE), 
                max(collisions.killed$LONGITUDE), max(collisions.killed$LATITUDE))
    })
  observeEvent(input$circlesize,{observeEvent(input$show_vars, {
    proxy <- leafletProxy("map2")%>%clearShapes()%>%
      addCircles(data = filter_( collisions.killed, paste0(input$show_vars, collapse = ' | '))%>% 
                   filter(DATE > input$dateRange2[1] & DATE < input$dateRange2[2]),
                 ~LONGITUDE, ~LATITUDE, 
                 color = ~color, radius = ~NUMBER.OF.PERSONS.KILLED*input$circlesize)
    
  })
  })
   
   
   
  output$plot <- renderPlot(
    ggplot(summarise(group_by(filter_(nyc.collisions, input$plot),year,BOROUGH),count = n()), 
           aes(x=year, y=count)) + facet_grid(~ BOROUGH) +
      geom_bar(stat = 'identity', aes(fill = BOROUGH)) +
      scale_fill_brewer(palette = 'Set1') +
      theme_classic()
    )
  
  data2 <- reactive({print(input$injratio)})
  
  
  output$injratio <- renderPlot(
    ggplot(head(arrange(inj.ratio,desc(ratio)), n= input$injslide),
           aes(x = VEHICLE.TYPE.CODE.1, y = ratio)) + 
      geom_bar(stat = 'identity', aes(fill = VEHICLE.TYPE.CODE.1)) +
      scale_fill_brewer(palette = 'Pastel1') +
      theme_classic()
  )
  
  output$motorcycles <- DT::renderDataTable({
    datatable(arrange(motorcycle.cause,desc(total.deaths)), rownames = FALSE) %>%
    formatStyle(input$selected,
                background = 'skyblue', fontWeight = 'bold')
  })

  output$table <- DT::renderDataTable({
    datatable(summarise(group_by(na.omit(nyc.collisions),Neighborhood),
                        BOROUGH = paste0(unique(BOROUGH), collapse = ','),
                        ZIP = paste0(unique(ZIP.CODE), collapse = ','),
                        CYCLISTS.K = sum(NUMBER.OF.CYCLIST.KILLED),
                        CYCLISTS.I = sum(NUMBER.OF.CYCLIST.INJURED),
                        PEDESTRIAN.K = sum(NUMBER.OF.PEDESTRIANS.KILLED),
                        PEDESTRIAN.I = sum(NUMBER.OF.PEDESTRIANS.INJURED),
                        MOTORIST.K = sum(NUMBER.OF.MOTORIST.KILLED),
                        MOTORIST.I = sum(NUMBER.OF.MOTORIST.INJURED),
                        total.deaths = sum(NUMBER.OF.PERSONS.KILLED))%>%
                arrange(desc(total.deaths)), rownames=FALSE) %>% 
      formatStyle(input$selected,  
                  background="skyblue", fontWeight='bold')
  })
  
  
  
  })