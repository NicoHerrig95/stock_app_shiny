#SERVER FILE

function(input, output){
  
  # Auto-refresh function
  autorefresh <- reactiveTimer(3600000) #1h = 3,600,000 ms.
  
  # creating reactive object for stock data generation, using 
  # scraper_getsymbols() function
  df_stock <- reactive({scraper_getsymbols(input$ticker_input,
                                           timespan = input$time)})
  
  
  # candle chart
  observeEvent(input$button,{
    output$StockPlot <- renderPlotly({
      autorefresh()
      plot_ly(data = df_stock(), 
              x = ~date,
              type = "candlestick",
              open = ~Open,
              close = ~Close, 
              high = ~High, 
              low = ~Low,
              name = "candles") %>% 
        add_lines(x = ~date, 
                  y = ~roll_avg, 
                  inherit = FALSE, 
                  line = list(color = "blue", width = 2),
                  name = "7d-rolling average") %>% 
        layout(xaxis = list(rangeslider = list(visible = FALSE)),
               yaxis = list(title = "closing price (USD)"))
    })
  })
  
  
  # plot for log-return chart
  observeEvent(input$button, {
    autorefresh()
    output$chart_returns <- renderPlotly({
      plot_ly(data = df_stock(),
              x = ~date,
              y = ~log_returns,
              name = 'trace 0',
              type = 'scatter',
              mode = 'lines') 
    })
  })
  
  # output table
  observeEvent(input$button,{
    output$table <- renderTable({
      autorefresh()
      table_filter <- subset(table_wiki, table_wiki$Symbol == input$ticker_input)
    })
  })
  
  # plot for log-return histogram
  observeEvent(input$button,{
    output$histo <- renderPlotly({
      autorefresh()
      plot_ly(data = df_stock(),
              x = ~log_returns,
              type = "histogram",
              alpha=0.7) %>% 
        layout(xaxis = list(title = "logarithmic returns"),
               yaxis = list(title = "frequency"),
               bargap=0.1)
    })
  })
  
  # generating data table
  observeEvent(input$button,{
    output$data <- DT::renderDataTable(
      autorefresh(),
      expr = datatable(df_stock(),
                       options = list(pageLength = 50),
                       rownames = FALSE)%>%
        formatRound(c(2:8), 2) %>% # rounding certain columns to 2 digits
        formatStyle(columns = c(2:9), 'text-align' = 'center')
    )
  })
  
  #generating download button 
  output$downloadData <- downloadHandler(
    filename = function() {
      paste(input$ticker_input,"-", Sys.Date(), ".csv", sep="")# file path
    },
    content = function(file) {
      write.csv(df_stock(), file)
    }
  )
  
}