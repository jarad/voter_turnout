library(shiny)
library(plyr)
library(ggplot2)
library(maps)
library(mapproj)

d = read.csv("1980-2014 November General Election - Turnout Rates.csv", skip=1)
d = rename(d, replace=c('X'                                 = 'State',
                        'Alphanumeric.State.Code'           = 'State_Code',
#                        'VEP.Total.Ballots.Counted'         = 'Voter_Turnout',
                        'Total.Ballots.Counted'             = 'n_ballots',
                         'Voting.Eligible.Population..VEP.' = 'VEP'))

d = d[-which(d$State=="United States (Excl. Louisiana)"),]

# Create input vectors
states = na.omit(unique(as.character(d$State)))
years  = sort(unique(d$Year, na.rm=TRUE))

# Calculate voter turnout
d$voter_turnout = d$Highest.Office/d$VEP


shinyServer(function(input,output) {
  # Set up UI from data frame
  output$selectYear = renderUI({ 
    selectInput("year", 
                label    = "Year:", 
                choices  = setNames(years, years), 
                selected = 2012)
  })
  
  output$selectState = renderUI({ 
    selectInput("state", 
                label    = "State:", 
                choices  = setNames(states, states), 
                selected = 'United States',
                multiple = TRUE)
  })
  
  # Restrict data frame according to user choices
  df = reactive({
    if (input$conditionedPanels == 1) {
      o = d[d$Year %in% input$year,]
    }
    if (input$conditionedPanels == 2) {
      o = d[d$State %in% input$state,]
    }
    o
  })
  
  # Voter turnout over time
  output$time_series = renderPlot({
    g = ggplot(df(), aes(x=Year, y=voter_turnout, col=State))+geom_point()
    print(g)
  })
  
  # Voter turnout by state
  output$map = renderPlot({
    mapstates = map_data("state")
    o = df()
    o$region = tolower(o$State)
    g = ggplot(merge(mapstates, o, sort = FALSE, by = 'region'), 
               aes(long, lat, group=group, fill=voter_turnout)) +
      geom_polygon() +
      coord_map(project="globular")
    print(g)
  })
})
