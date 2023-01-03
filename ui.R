# USER INTERFACE FILE


dashboardPage(
  dashboardHeader(title= shinyDashboardLogo( # creating logo of the app
    theme = "blue_gradient",
    boldText = "STOCK SEEKER",
    mainText = "DOW30",
    badgeText = "v1.1")
  ),
  # defining menu items of sidebar
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "Overview", icon = icon("dashboard")),
      menuItem("Data", tabName = "Data", icon = icon("th"))
    ),
    # other items included in dashboard sidebar
    # input panel for ticker
    selectInput(inputId = "ticker_input",
                label = "select ticker",
                selected = NULL,
                multiple = FALSE,
                choices = table_wiki$Symbol),
    # radio buttons for time frame of interest
    radioButtons(inputId = "time",
                 label = "select timeframe",
                 choiceNames  = timespan$names,
                 choiceValues = timespan$values,
                 selected = NULL,
                 inline = FALSE),
    # action button to refresh/load data
    actionButton(inputId = "button",
                 label = "load / refresh",
                 icon = icon("expand"))
    
  ),
  
  # main body 
  dashboardBody(
    # setting design of application
    shinyDashboardThemes(
      theme = "blue_gradient"
    ),
    
    tabItems(
      # first tab item: Overview page
      tabItem(tabName = "Overview",
              fluidPage(
                title = "Overview",
                
                # first element: information table
                fluidRow(
                  tableOutput("table"), # 
                  align = "center"
                ),
                
                # second element: Panel
                fluidRow(
                  tabsetPanel( #candle chart
                    tabPanel("candle chart",
                             plotlyOutput(outputId = "StockPlot",
                                          height = "600px")
                    ),
                    tabPanel("logarithmic returns (time series)", #log chart
                             plotlyOutput(outputId = "chart_returns",
                                          height = "600px")
                    ),
                    tabPanel("logarithmic returns (distribution)", #log distrb.
                             plotlyOutput(outputId = "histo",
                                          height = "600px")
                    )
                  ),
                  align = "center"
                ),
              )
      ),
      #second tab of dashboard
      tabItem(tabName = "Data",
              fluidPage(
                sidebarLayout(
                  sidebarPanel( #download button
                    downloadButton("downloadData", "Download csv"), 
                    width = 2
                  ),
                  
                  # price table
                  mainPanel(
                    dataTableOutput("data"),
                    width = 8
                  )
                )
              )
      )
    )
  )
)
