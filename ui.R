#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)

campaigns_list <- list("adjective (ADJ)","noun(NOUN)","proper noun (PROPN)","adverb (ADV)","verb (VERB)")

shinyUI(
  fluidPage(
    tags$head(
      tags$style(
        HTML(".shiny-notification {
             height: 50px;
             width: 500px;
             position:fixed;
             top: calc(50% - 50px);;
             left: calc(50% - 400px);;
             }
             "
        )
        )),
    
    titlePanel("NLP using UD-Pipe"),  # name the shiny app
    
    sidebarLayout(    # creates a sidebar layout to be filled in
      
      sidebarPanel(   # creates a panel struc in the sidebar layout
        
        
        # user reads input file into input box here:
        fileInput("file1", 
                  "Upload data file"),
        checkboxGroupInput("PartsofSpeech","Choose POS:",campaigns_list)
        
       
      ),   # end of sidebar panel
      
      ## Main Panel area begins.
      mainPanel(
        
        tabsetPanel(type = "tabs",   # builds tab struc
                    
                    tabPanel("Overview",   # leftmost tab
                             
                             h4(p("Data input")),
                             
                             p("This app supports any kind of document", align="justify"),
                             
                             p("Please refer to the link below for sample  file."),
                             a(href="https://github.com/PoonamSampat/SampleDataSet/blob/master/Shinytestdata.txt"
                               ,"Sample data input file"),   
                             
                             br(),
                             
                             h4('How to use this App'),
                             
                             p('To use this app, click on', 
                               span(strong("Upload data ")),
                               'and upload the data file. You can also select list of Universal part-of-speech tags (upos) using check box for plotting co-occurrences. '),
                            
                             p('This app converts the given document into an Annotated document, breaking each sentence into',
                              'noun,verb,adj.., helps visualize the Parts of Speech, and also give the co-occurance of the words.')),
                              
                    
                            
                    
                    # second tab coming up:
                    tabPanel("Annoted Documents", 
                             actionButton("Download", "Download"),
                             
                             # plot1 object returned by server.R
                             tableOutput('Summary')),
                    
                    # third tab coming up:
                    tabPanel("Word Clouds",
                             
                             # obj 'clust_summary' from server.R
                             plotOutput('WordCloud'),
                             plotOutput('WordCloudVerb')),
                    
                    # fourth tab coming up:
                    tabPanel("Co-Occurencess",
                             
                          plotOutput('Cooccurance')),
                    
                    # fifth tab coming up:
                    tabPanel("Word Extraction",
                             
                             plotOutput('KeyWordExtraction'))
                    
        ) # end of tabsetPanel
      )# end of main panel
    ) # end of sidebarLayout
  )  # end if fluidPage
) # end of UI
    
    
    



