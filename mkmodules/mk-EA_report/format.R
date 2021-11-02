# Load libs
library("dplyr")
library("ggplot2")
library("scales")

## Read args from command line
args = commandArgs( trailingOnly = TRUE )

## Uncomment For debugging only
## Comment for production mode only
# args[1] <- "test/data/sample_query.fa.with_nohits.tsv" ## %.fa.with_nohits.tsv
# args[2] <- "test/data/sample_query_EA_report.tsv" ## %_EA_report.tsv

## Passing args to named objects
ifile <- args[1]
ofile <- args[2]

# Read data
EAdata <- read.csv( file = ifile, sep = "\t", na.strings = "." )

# calculate categories of changes in pident  ====
# find queries with ea pident lower than blast pident
lower <- EAdata %>% 
  filter( extend_align_pident < pident )

# find queries with ea pident higher than blast pident
higher <- EAdata %>% 
  filter( extend_align_pident > pident )

# find queries with ea pident same as blast pident
same <- EAdata %>% 
  filter( extend_align_pident == pident )

# find no hits
nohit <- EAdata %>% 
  filter( sseqid == "NO_HIT" )

# Plot a donut with the changes
donut_data <- data.frame( category = c("higher", "same", "lower", "nohit"),
                          counts = c( nrow( higher ),
                                      nrow( same ),
                                      nrow( lower ),
                                      nrow( nohit ) ) ) %>% 
  mutate( proportion = counts / sum( counts ),
          # percent = percent( proportion, accuracy = 0.1 ),   # Commented due to incompatibility with R version 3.3
         percent = paste(round(proportion * 100, digits = 2), "%"),
          tag = paste( category, percent ) )

donut <- ggplot( data = donut_data,
                 mapping = aes( x = 2,
                                y = proportion,
                                fill = tag ) ) +
  geom_col( color = "black" ) +
  xlim( c( 1, 2.5 ) ) +
  coord_polar( theta = "y" ) +
  labs( title = "Summary of Extend Align Identity Recalculation",
        subtitle = paste( "Total queries:", nrow( EAdata ) %>% prettyNum( big.mark = ",") ),
        caption = paste( ifile, "ANALYZED on", Sys.time( ) ) ,
        fill = "EA pident vs blastn pident" ) +
  scale_fill_brewer( palette = "Paired" ) +
  theme_void( base_size = 16 ) +
  theme( plot.background = element_rect( fill = "white" ),
         plot.title = element_text( hjust = 0.5 ),
         plot.subtitle = element_text( hjust = 0.5 ),
         legend.position = "bottom" )

# clean DF to only useful columns ====
selected <- EAdata %>% 
  select( qseqid,
          sseqid,
          qmismatch_in_gap,
          query_mismatch,
          extended_5end_mismatch,
          extended_3end_mismatch,
          query_overhang_5end_mismatch,
          query_overhang_3end_mismatch,
          total_mismatch,
          qlength,
          # pident,
          extend_align_pident
          ) %>% 
  mutate( EA_total_match = qlength - total_mismatch ) %>%
  rename( query_gap = qmismatch_in_gap )

# Save outputs
# save table
write.table( x = selected,
             file = ofile,
             sep = "\t",
             na = ".",
             append = FALSE, quote = FALSE,
             row.names = FALSE, col.names = TRUE )

# save plot
ggsave( filename = ofile %>% gsub( pattern = "\\.tsv", replacement = "\\.png" ),
        plot = donut,
        width = 10,
        height = 10,
        dpi = 300 )
