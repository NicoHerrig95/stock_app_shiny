# USER INTERFACE FILE
dashboardPage(
  # Browser Title
  title = "Stock Seeker DOW30",

  # Header
  dashboardHeader(

    # Create logo of the app
    title = shinyDashboardLogo(
      theme = "blue_gradient",
      boldText = "STOCK SEEKER",
      mainText = "DOW30",
      badgeText = "v1.1"
    ),

    # Add 'contact us' option
    dropdownMenu(
      type = "messages",
      headerText = strong("Feedback and susggestions"),
      messageItem(
        from = "angus@st-andrews.ac.uk",
        message =  "",
        icon = icon("envelope"),
        href = "mailto:angus@st-andrews.ac.uk"
      ),
      icon = icon("comment")
    ),

    # Add share option
    dropdownMenu(
      type = "message",
      icon = icon("share-alt"),
      headerText = strong("Like it Share it"),

      # Twitter
      messageItem(
        from = "Twitter",
        message = "",
        icon = icon("twitter"),
        href = "https://twitter.com/intent/tweet?url=https://nicohrg95.shinyapps.io/stock_seeker/&text=Check%20out%20Stock%20Seeker%20Dow30%20Dashboard"
      ),

      # Facebook
      messageItem(
        from = "Facebook",
        message = "",
        icon = icon("facebook"),
        href = "https://www.facebook.com/sharer/sharer.php?u=https://nicohrg95.shinyapps.io/stock_seeker/"
      ),

      # LinkedIn
      messageItem(
        from = "LinkedIn",
        message = "",
        icon = icon("linkedin"),
        href = "http://www.linkedin.com/shareArticle?mini=true&url=https://nicohrg95.shinyapps.io/stock_seeker/&title=Stock%20Seeker%20Dow30%20Dashboard"
      )
    ),

    # Link to github README
    tags$li(
      a(
        strong("ABOUT Stock Seeker"),
        height = 40,
        href = "https://github.com/Joseph-Edwards/MT5763_Shiny/blob/main/stock_seeker/Readme.md",
        title = "",
        target = "_blank"
      ),
      class = "dropdown"
    )
  ),

  # Create side bar menu with 'Overview' and 'Data' options
  dashboardSidebar(
    sidebarMenu(
      menuItem("Overview", tabName = "Overview", icon = icon("dashboard")),
      menuItem("Data", tabName = "Data", icon = icon("th"))
    ),

    # Create stock ticker input selection with place holder value
    selectizeInput(
      inputId = "ticker_input",
      label = "select ticker",
      selected = NULL,
      multiple = FALSE,
      choices = table_wiki$Symbol,
      options = list(
        placeholder = "Please select ticker",
        onInitialize = I('function() { this.setValue(""); }')
      )
    ),

    # If the user has selected a ticker, show them timespan radio buttons
    conditionalPanel(
      condition = "input.ticker_input != ''",
      radioButtons(
        inputId = "time",
        label = "select timeframe",
        choiceNames = timespan$names,
        choiceValues = timespan$values,
        inline = FALSE
      ),

      # Create button to refresh data
      actionButton(
        inputId = "button",
        label = "refresh",
        icon = icon("expand")
      )
    ),

    # Adjust colours of headings and visibility of notifications
    tags$script(HTML(
      "document.querySelector('#showcase-app-container > div > header > nav > div > ul > li:nth-child(1) > a > span').style.visibility = 'hidden';
       document.querySelector('#showcase-app-container > div > header > nav > div > ul > li:nth-child(2) > a > span').style.visibility = 'hidden';
       document.querySelector('#showcase-app-container > div > header > nav > div > ul > li:nth-child(1) > a > i').style.color = '#4b4b4b';
       document.querySelector('#showcase-app-container > div > header > nav > div > ul > li:nth-child(2) > a > i').style.color = '#4b4b4b';
       document.querySelector('#showcase-app-container > div > header > nav > div > ul > li:nth-child(3) > a > strong').style.color = '#4b4b4b';"
    ))
  ),

  # Main body
  dashboardBody(

    # Set design of application
    shinyDashboardThemes(
      theme = "blue_gradient"
    ),

    # Create 'Overview' and 'Data' tabs
    tabItems(

      # First tab item: Overview page
      tabItem(
        tabName = "Overview",
        fluidPage(
          title = "Overview",

          # Tell the user to select a ticker if they haven't already
          conditionalPanel(
            condition = "input.ticker_input == ''",
            fluidRow(
              textOutput("txt_select_ticker", inline = TRUE),
              align = "center"
            )
          ),

          # Show data and
          conditionalPanel(
            condition = "input.ticker_input != ''",
            # First element: Stock information table
            fluidRow(
              tableOutput("table"), #
              align = "center"
            ),

            # Second element: Tab panel
            fluidRow(
              tabsetPanel(

                # Candle chart
                tabPanel(
                  "candle chart",
                  plotlyOutput(
                    outputId = "StockPlot",
                    height = "600px"
                  ),
                  tags$style(type = "text/css", "a{color: #000000;}")
                ),

                # Log returns chart
                tabPanel(
                  "logarithmic returns (time series)",
                  plotlyOutput(
                    outputId = "chart_returns",
                    height = "600px"
                  )
                ),

                # Log returns distribution histogram
                tabPanel(
                  "logarithmic returns (distribution)",
                  plotlyOutput(
                    outputId = "histo",
                    height = "600px"
                  )
                )
              ),
              align = "center"
            )
          ),
        )
      ),

      # Second tab: Data and download option
      tabItem(
        tabName = "Data",
        fluidPage(
          title = "Data",

          # Ask the user to select a stock if they haven't already done so
          conditionalPanel(
            condition = "input.ticker_input == ''",
            fluidRow(
              textOutput("txt_select_ticker_2", inline = TRUE),
              align = "center"
            )
          ),

          # If the user has selected a stock, show the data and an option to
          # download
          conditionalPanel(
            condition = "input.ticker_input != ''",
            fluidRow(
              column(
                downloadButton("downloadData", "Download csv"),
                width = 12,
                align = "left",
                style = "padding:10px;"
              ),
              column(
                dataTableOutput("data"),
                width = 12,
                align = "center"
              )
            )
          )
        )
      )
    )
  )
)
