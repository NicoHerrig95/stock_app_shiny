# SERVER FILE

# Colours to be used in plots
plot_colour <- "#1685A9" # Dark Teal

function(input, output) {
  # Set place holder text for unselected ticker
  output$txt_select_ticker <- renderText("Please select a ticker to retrieve its data")
  output$txt_select_ticker_2 <- renderText("Please select a ticker to retrieve its data")

  # Auto-refresh function
  autorefresh <- reactiveTimer(3600000) # 1h = 3,600,000 ms.

  # Create reactive object for stock data generation
  df_stock <- reactive({
    scraper_get_symbols(input$ticker_input,
      timespan = input$time
    )
  })

  # Create reactive object to see when the data needs to be updated based on
  # user action
  update_data_listener <- reactive({
    list(input$button, input$ticker_input)
  })

  # Candle chart when data updates
  observeEvent(update_data_listener(), {
    if (input$ticker_input != "") {
      output$StockPlot <- renderPlotly({
        autorefresh()
        plot_ly(
          data = df_stock(),
          x = ~date,
          type = "candlestick",
          open = ~Open,
          close = ~Close,
          high = ~High,
          low = ~Low,
          name = "candles"
        ) %>%
          add_lines(
            x = ~date,
            y = ~roll_avg,
            inherit = FALSE,
            line = list(color = plot_colour, width = 2),
            name = "7d-rolling average"
          ) %>%
          layout(
            xaxis = list(rangeslider = list(visible = FALSE)),
            yaxis = list(title = "closing price (USD)")
          )
      })
    }
  })

  # Create log-return chart when data updates
  observeEvent(update_data_listener(), {
    if (input$ticker_input != "") {
      autorefresh()
      output$chart_returns <- renderPlotly({
        plot_ly(
          data = df_stock(),
          x = ~date,
          y = ~log_returns,
          name = "trace 0",
          type = "scatter",
          mode = "lines",
          color = I(plot_colour)
        ) %>%
          layout(
            xaxis = list(title = "date"),
            yaxis = list(title = "logarithmic returns")
          )
      })
    }
  })

  # Create log-return histogram when data updates
  observeEvent(update_data_listener(), {
    if (input$ticker_input != "") {
      output$histo <- renderPlotly({
        autorefresh()
        plot_ly(
          data = df_stock(),
          x = ~log_returns,
          type = "histogram",
          alpha = 0.7,
          color = I(plot_colour)
        ) %>%
          layout(
            xaxis = list(title = "logarithmic returns"),
            yaxis = list(title = "frequency"),
            bargap = 0.1
          )
      })
    }
  })

  # Create output data table when data updates
  observeEvent(update_data_listener(), {
    if (input$ticker_input != "") {
      output$table <- renderTable({
        autorefresh()
        table_filter <- subset(table_wiki, table_wiki$Symbol == input$ticker_input)
      })
    }
  })

  # Generate data table when data updates
  observeEvent(update_data_listener(), {
    if (input$ticker_input != "") {
      output$data <- DT::renderDataTable(
        autorefresh(),
        expr = datatable(df_stock(),
          options = list(pageLength = 50),
          rownames = FALSE
        ) %>%
          formatRound(c(2:8), 2) %>% # rounding certain columns to 2 digits
          formatStyle(columns = c(2:9), "text-align" = "center")
      )
    }
  })

  # Create download button
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$ticker_input, "-", Sys.Date(), ".csv", sep = "") # file path
    },
    content = function(file) {
      write.csv(df_stock(), file)
    }
  )
}
