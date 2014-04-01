library(ggplot2)
library(scales)
library(shiny)

# load data
data("movies", package = "ggplot2")

# create genre variable
genre <- rep(NA, nrow(movies))
count <- rowSums(movies[, 18:24])
genre[which(count > 1)] = "Mixed"
genre[which(count < 1)] = "None"
genre[which(count == 1 & movies$Action == 1)] = "Action"
genre[which(count == 1 & movies$Animation == 1)] = "Animation"
genre[which(count == 1 & movies$Comedy == 1)] = "Comedy"
genre[which(count == 1 & movies$Drama == 1)] = "Drama"
genre[which(count == 1 & movies$Documentary == 1)] = "Documentary"
genre[which(count == 1 & movies$Romance == 1)] = "Romance"
genre[which(count == 1 & movies$Short == 1)] = "Short"
movies$genre = as.factor(genre)

# subset data
movies_subset <- subset(movies, movies$budget > 0 & movies$mpaa != '' )

# for formatting budget values
million_formatter <- function(x) {
  return(sprintf("$%dM", x / 1000000))
}


getPlot <- function(localFrame, colorScheme = "Default", highlight, ratingsToShow, alpha_level, point_size) {
  if (ratingsToShow != 'All'){
    localFrame <- localFrame[which(localFrame$mpaa == ratingsToShow),] 
  }
  if (length(highlight) != 0){
    localFrame <- localFrame[which(localFrame$genre %in% highlight),]
  }
  localPlot <- ggplot(localFrame, aes(x = as.numeric(budget), y = rating, color = factor(mpaa))) +
    geom_point(size = point_size, alpha = alpha_level)+
    scale_x_continuous(limits = c(0, 200000000), label = million_formatter, expand = c(0, 2500000)) +
    scale_y_continuous(limits = c(0, 10), expand = c(0, 0.25)) + 
    theme(axis.ticks.x = element_blank()) +
    theme(axis.text.y = element_text(size = 12)) +
    theme(axis.text.x = element_text(size = 12)) +
    theme(legend.position = 'bottom') + 
    xlab('Budget') + ylab('Rating') + 
    ggtitle("Movie Ratings by Budget")
  
  mpaas <- levels(localFrame$mpaa)
  
  if (colorScheme == "Pastel 1") {
    my_palette <- brewer_pal(type = "qual", palette = 'Pastel1')(length(mpaas))
  }
  else if (colorScheme == "Accent") {
    my_palette <- brewer_pal(type = "qual", palette = 'Accent')(length(mpaas))
  }
  else if (colorScheme == "Set 1") {
    my_palette <- brewer_pal(type = "qual", palette = 'Set1')(length(mpaas))
  }
  else if (colorScheme == "Set 2") {
    my_palette <- brewer_pal(type = "qual", palette = 'Set2')(length(mpaas))
  }
  else if (colorScheme == "Set 3") {
    my_palette <- brewer_pal(type = "qual", palette = 'Set3')(length(mpaas))
  }
  else if (colorScheme == "Dark 2") {
    my_palette <- brewer_pal(type = "qual", palette = 'Dark2')(length(mpaas))
  }
  else if (colorScheme == "Pastel 2") {
    my_palette <- brewer_pal(type = "qual", palette = 'Pastel2')(length(mpaas))
  }
  else if (colorScheme == 'Default'){
    return(localPlot + scale_color_discrete(name = 'MPAA Rating'))
  }
#  my_palette[which(!genres %in% highlight)] <- "#EEEEEE"
  localPlot <- localPlot + scale_color_manual(values = my_palette, name = 'MPAA Rating')
  return(localPlot)
}


shinyServer(function(input, output) {
  
  cat("Press \"ESC\" to exit...\n")
  
  # Copy the data frame (don't want to change the data
  # frame for other viewers)
  localFrame <- movies_subset
  
  
output$scatterPlot <- renderPlot(
{
  # Use our function to generate the plot.
  scatterPlot <- getPlot(
    localFrame,
    input$colorScheme, 
    input$highlight, 
    input$ratingsToShow, 
    input$alpha, 
    input$size
  )
  
  # Output the plot
  print(scatterPlot)
}
)
})

  