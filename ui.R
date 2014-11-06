require(shiny)
require(markdown)

shinyUI(pageWithSidebar(
  headerPanel("Voter turnout 1980-2012 (2014 soon)"),
  sidebarPanel(
    conditionalPanel(
      condition='input.conditionedPanels==1',
      htmlOutput('selectYear')
    ),
    conditionalPanel(
      condition='input.conditionedPanels==2',
      htmlOutput('selectState')
    ) 
  ),
  mainPanel(
    tabsetPanel(
      tabPanel("Geographically", 
               plotOutput('map'),
               value=1), 
      tabPanel("Time Series", 
               plotOutput('time_series'),
               value=2),
      tabPanel('Help', includeMarkdown('help.md'), value=3)
      , id = "conditionedPanels"
    )
  )
))