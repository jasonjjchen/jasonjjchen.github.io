## ui.R ##
shinyUI(dashboardPage(skin = 'purple',
  dashboardHeader(title = 'Car Accidents in NYC'),
  dashboardSidebar(
    sidebarUserPanel('@@@@@HELLO ^_^@@@@@@@@@@@'),
    sidebarMenu(id = 'sideBarMenu',
      menuItem("Heat Map of Accidents", tabName = "map1", icon = icon("map")),
      
      menuItem("By Year and Borough", tabName = "plot", icon = icon("bar-chart-o")),
      
      menuItem("Fatalities", tabName = "map2", icon = icon("map")),
      
      menuItem("By Neighborhood", tabName = "table", icon = icon("database")),
      
      menuItem("Highest Injury Ratio?", tabName = "injratio", icon = icon("bar-chart-o"),
      menuSubItem("Injury/Death to Accidents", tabName = "injratio",icon = icon("bar-chart-o")),
      menuSubItem("Top Contributing Factors", tabName = "motorcycles",icon = icon("play")),
      menuSubItem("Motorcycle Accidents", tabName = "mmap",icon = icon("play"))
      ),
      
      conditionalPanel("input.sideBarMenu == 'map1'",
                       selectizeInput('borough',
                                      'BOROUGH',
                                      choice = c('All' = 'BOROUGH != ""',
                                                 'Brooklyn' = 'BOROUGH == "BROOKLYN"',
                                                 'Bronx' = 'BOROUGH == "BRONX"',
                                                 'Queens' = 'BOROUGH == "QUEENS"',
                                                 'Staten Island' = 'BOROUGH == "STATEN ISLAND"',
                                                 'Manhattan' = 'BOROUGH == "MANHATTAN"')),
                       selectizeInput('filter',
                                      'Number of Vehicles Involved: ',
                                      choice = c('All' = 'no.of.cars > 0',
                                                 '1' = 'no.of.cars == 1',
                                                 '2' = 'no.of.cars == 2',
                                                 '3' = 'no.of.cars == 3',
                                                 '4' = 'no.of.cars == 4',
                                                 '5' = 'no.of.cars == 5',
                                                 '3+' = 'no.of.cars > 3')),
                       sliderInput('heatslide', label = 'Set size of radius (in meters): ', 
                                   min = 0, max = 2000, value = 200, step = 100),
                       dateRangeInput('dateRange',
                                      label = 'Date range input: yyyy-mm-dd',
                                      start = '2012-01-01', end = '2016-12-31'),
                       
                       radioButtons("time1", "Select time: ",
                                    c("12:00 am - 6:00 am" = 1,
                                      "6:00 am - 12:00 pm" = 2,
                                      "12:00 pm - 6:00 pm" = 3,
                                      "6:00 pm - 12:00 am" = 4))
                       
                       
      ),
      conditionalPanel("input.sideBarMenu == 'map2'",
                       checkboxGroupInput('show_vars', 'Select group: ',
                                          c('Pedestrians - Red' = 'NUMBER.OF.PEDESTRIANS.KILLED > 0',
                                            'Cyclists - Green' = 'NUMBER.OF.CYCLIST.KILLED > 0',
                                            'Motorists - Blue' = 'NUMBER.OF.MOTORIST.KILLED > 0')),
                       #                    selected = c('NUMBER.OF.PEDESTRIANS.KILLED > 0',
                       #                                 'NUMBER.OF.CYCLIST.KILLED > 0',
                       #                                 'NUMBER.OF.MOTORIST.KILLED > 0')),
                       
                       sliderInput('circlesize', label = 'Circle size :', 
                                   min = 10, max = 500, value = 200, step = 50),
                       
                       dateRangeInput('dateRange2',
                                      label = 'Date range input: yyyy-mm-dd',
                                      start = '2012-01-01', end = '2016-12-31')
      ),
      conditionalPanel("input.sideBarMenu == 'plot'",
                       selectizeInput('plot',
                                      'Accidents by casualties: ',
                                      choice = c('All' = "NUMBER.OF.PERSONS.KILLED != ''",
                                                 'Injured or Killed' = 'NUMBER.OF.PERSONS.KILLED != 0 | NUMBER.OF.PERSONS.INJURED !=0',
                                                 'Unharmed' = 'NUMBER.OF.PERSONS.KILLED == 0 | NUMBER.OF.CYCLIST.INJURED ==0'))
                       
      ),
      
      conditionalPanel("input.sideBarMenu == 'injratio'",
                       sliderInput('injslide', label = 'Show up to :', 
                                   min = 1, max = 9, value = 5)
      )
      
      )
    

    ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "map1",
              fluidRow(box(
                leafletOutput("map1", 
                              height = 650),
                width = 12))),
      
      tabItem(tabName = "map2",
              fluidRow(box(
                leafletOutput("map2", 
                              height = 650),
                width = 12))),
      
      tabItem(tabName = "plot",
              fluidRow(box(
                plotOutput('plot'),
                width = 12))),
      
      tabItem(tabName = "table",
              fluidRow(box(
                DT::dataTableOutput("table"),
                width = 12))),
      
      tabItem(tabName = "injratio",
              fluidRow(box(
                plotOutput('injratio'),
                width = 12))),
      
      tabItem(tabName = "motorcycles",
              fluidRow(box(
                DT::dataTableOutput('motorcycles'),
                width = 12)))

            
      )
    )
))

