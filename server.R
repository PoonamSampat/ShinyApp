#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
if (!require(udpipe)){install.packages("udpipe")}
if (!require(textrank)){install.packages("textrank")}
if (!require(lattice)){install.packages("lattice")}
if (!require(igraph)){install.packages("igraph")}
if (!require(ggraph)){install.packages("ggraph")}
if (!require(wordcloud)){install.packages("wordcloud")}
if (!require(repmis)){install.packages("repmis")}

library(udpipe)
library(textrank)
library(lattice)
library(igraph)
library(ggraph)
library(ggplot2)
library(wordcloud)
library(stringr)
library(repmis)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session ) {
   
     
     selectedData <- reactive({
       readLines(input$file1$datapath)
     })
     
     downloadData <- reactive({
       
       setwd('C:\\Users\\H219960\\Desktop\\Personal\\ISB\\Classes\\Term1');  getwd()
       
       df <- selectedData()
       
       df  =  str_replace_all(df, "<.*?>", "") # get rid of html junk 
       
       
       # ?udpipe_download_model   # for langu listing and other details
       
       # load english model for annotation from working dir
       english_model = udpipe_load_model("./english-ud-2.0-170801.udpipe")  # file_model only needed
       
       
       # now annotate text dataset using ud_model above
       # system.time({   # ~ depends on corpus size
      
       x <- udpipe_annotate(english_model, x = df) #%>% as.data.frame() %>% head()
       x <- as.data.frame(x)
       
       
       return (head(x, 50))
       
     })

     
 
     output$Summary <- renderTable({
       
       progress <- Progress$new(session, min=1, max=15)
       on.exit(progress$close())
       
       progress$set(message = 'Calculation in progress',
                    detail = 'This may take a while...')
       for (i in 1:15) {
         progress$set(value = i)
         Sys.sleep(0.5)
       }
       
       return (downloadData())
       
     })
     
     top_nouns <- reactive({
     
       table(downloadData()$xpos)  # std penn treebank based POStags
       table(downloadData()$upos)  # UD based postags
       
       # So what're the most common nouns? verbs?
       all_nouns = downloadData() %>% subset(., upos %in% "NOUN") 
       top_nouns = txt_freq(all_nouns$lemma)  # txt_freq() calcs noun freqs in desc order
       top_nouns
       
     })
     
     top_verbs <- reactive({
       
       table(downloadData()$xpos)  # std penn treebank based POStags
       table(downloadData()$upos)  # UD based postags
       
       
       all_verbs =downloadData()  %>% subset(., upos %in% "VERB") 
       top_verbs = txt_freq(all_verbs$lemma)
       (head(top_verbs, 100))
       
     })
     
     output$WordCloud <- renderPlot({
       
       title = "Noun's Word Cloud"
       wordcloud(words = top_nouns()$key, 
                 freq = top_nouns()$freq, 
                 scale = c(3.5, 0.5),
                 min.freq = 2, 
                 max.words = 100,
                 random.order = FALSE,
                 main="Noun's WordCloud",
                 colors = brewer.pal(8, "Dark2"))
       title(sub = title) 
     })
     
     output$WordCloudVerb <- renderPlot({
       
       title = "Verb's Word Cloud"
       wordcloud(words = top_verbs()$key, 
                 freq = top_verbs()$freq, 
                 scale = c(3.5, 0.5),
                 min.freq = 2, 
                 max.words = 100,
                 random.order = FALSE,
                 colors = brewer.pal(8,"BrBG"))
       title(sub = title) 
     })
     
     
     getcooccurrence <- reactive({
     
     # Sentence Co-occurrences for nouns or adj only
     cooc <- cooccurrence(   	# try `?cooccurrence` for parm options
       x = subset(downloadData(), upos %in% c("NOUN", "VERB")), 
       term = "lemma", 
       group = c("doc_id", "paragraph_id", "sentence_id"))  # 0.02 secs
     # str(nokia_cooc)
     head(cooc)
     
     
     })
     
     
     output$Cooccurance<- renderPlot({
     
     wordnetwork <- head(getcooccurrence(), 50)
     wordnetwork <- igraph::graph_from_data_frame(wordnetwork) # needs edgelist in first 2 colms.
     
     ggraph(wordnetwork, layout = "fr") +  
       
       geom_edge_link(aes(width = cooc, edge_alpha = cooc), edge_colour = "orange") +  
       geom_node_text(aes(label = name), col = "darkgreen", size = 4) +
       
       theme_graph(base_family = "Arial Narrow") +  
       theme(legend.position = "none") +
       
       
       labs(title = "Cooccurrences within 3 words distance", subtitle = "Nouns & Verb")
     })       
     
     
     output$KeyWordExtraction<-renderPlot({
     ## Using RAKE
     stats <- keywords_rake(downloadData(), term = "lemma", group = "doc_id", 
                            relevant = downloadData()$upos %in% c("NOUN", "VERB"))
     stats$key <- factor(stats$keyword, levels = rev(stats$keyword))
     barchart(key ~ rake, data = head(subset(stats, freq > 3), 20), col = "red", 
              main = "Keywords identified by RAKE", 
              xlab = "Rake")
     })
     
    
  
    
  
})
