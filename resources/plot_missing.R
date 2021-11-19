library(tidyverse)
library(patchwork)

plot_missing <- function(df, percent = FALSE) {
  missing_patterns <- data.frame(is.na(df)) %>%
    group_by_all() %>%
    count(name = "count", sort = TRUE) %>%
    ungroup()
  
  lev = c(1:nrow(missing_patterns))
  lev = as.factor(lev)
  
  # num row missing
  val <- integer(ncol(missing_patterns))
  per <- numeric(ncol(missing_patterns))
  
  for (i in 1:nrow(missing_patterns)){
    for (j in 1:length(names(missing_patterns))){
      if (missing_patterns[i, names(missing_patterns)[j]] == TRUE){
        val[j] = val[j] + missing_patterns[i, 'count']
      }
    }
  }
  val = unlist(val)
  index <- order(val, decreasing = TRUE)
  val <- val[index]
  
  per = unlist(per)
  for (i in 1:ncol(missing_patterns)){
    per[i] = val[i]*100/nrow(df)
  }
  
  sorted_label <- names(missing_patterns)[index]
  
  new_df <- data.frame(sorted_label, val)
  new_df$sorted_label <- factor(new_df$sorted_label, levels = new_df$sorted_label)
  new_df['per'] <- per
  new_df <- new_df %>% filter(sorted_label != 'count')
  
  
  if (percent == FALSE){
    p1 <- ggplot(data = new_df, aes(x = sorted_label, y = val)) + geom_bar(stat = 'identity', fill = "cornflowerblue", alpha = 0.5) + scale_x_discrete(labels = abbreviate) + coord_cartesian(ylim = c(0, max(val))) + xlab(label = NULL) + ylab(label = expression(paste("num rows\nmissing:"))) + theme_minimal() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  }
  else{
    p1 <- ggplot(data = new_df, aes(x = sorted_label, y = per)) + geom_bar(stat = 'identity', fill = "cornflowerblue", alpha = 0.5) + scale_x_discrete(labels = abbreviate) + coord_cartesian(ylim = c(0, 100)) + xlab(label = NULL) + ylab(label = expression(paste("% rows\nmissing:"))) + theme_minimal() + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))
  }
  
  # plot for missing pattern VS variable
  clean_df <- missing_patterns %>% 
    rownames_to_column('id') %>% 
    gather(key, value, -id) %>% 
    mutate(missing = ifelse(value == 1, "yes", "no"))
  
  missing_patterns_new <- missing_patterns %>% 
    mutate(sum = rowSums(.)-count)
  
  m_index = c()
  for (i in 1:length(missing_patterns_new$sum)){
    if (missing_patterns_new[i, 'sum'] == 0){
      m_index <- append(m_index, i)
    }
  }
  
  cc <- clean_df %>% 
    filter(key != 'count') %>% 
    group_by(id) %>% 
    summarize(value = sum(value))
  
  clean_df <- clean_df %>% filter(key != 'count')
  sorted_label <- sorted_label[sorted_label != 'count']
  
  p2 <- ggplot(clean_df) + geom_tile(aes(x = key, y = id, fill = missing), fill = ifelse(clean_df$missing == 'yes', 'purple1', 'grey60'), color = 'white', alpha = ifelse(clean_df$id %in% m_index, 1, 0.5)) + scale_x_discrete(limits = sorted_label, labels = abbreviate) + scale_y_discrete(limits = rev(levels(lev))) + labs(x = "variable", y = "missing pattern") + theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)) + annotate("text", x = as.integer((ncol(missing_patterns)-1)/2)+1, y = nrow(missing_patterns)-m_index+1, label = "Complete Cases")
  
  
  # missing row count plot
  if (percent == FALSE){
    p3 <- ggplot(data = missing_patterns_new, aes(y = count, x = lev)) + geom_bar(stat = 'identity', fill = "cornflowerblue", alpha = ifelse(missing_patterns_new$sum == 0, 1, 0.5)) + coord_flip() + scale_x_discrete(limits = rev(levels(lev))) + ylab(label = "row count") + xlab(label = NULL) + theme_minimal()
  }
  else {
    per_2 = numeric(nrow(missing_patterns_new))
    per_2 <- unlist(per_2)
    
    for (i in 1:nrow(missing_patterns_new)){
      per_2[i] = missing_patterns_new[i, 'count']*100 / sum(missing_patterns_new$count)
    }
    
    p3 <- ggplot(data = missing_patterns_new, aes(y = per_2, x = lev)) + geom_bar(stat = 'identity', fill = "cornflowerblue", alpha = ifelse(missing_patterns_new$sum == 0, 1, 0.5)) + coord_flip() + scale_x_discrete(limits = rev(levels(lev))) + ylab(label = "% rows") + xlab(label = NULL) + theme_minimal()
  }
  
  # patchwork
  final_plot <- p1 + plot_spacer() + p2 + p3 + plot_annotation(subtitle = 'Missing value Patterns') + plot_layout(widths = unit(c(2, 2), c('null', 'cm')), heights = unit(c(2, 2), c('cm', 'null')))
  
  return(plot(final_plot))
}