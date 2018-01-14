## OSM Polygon Grabber - polygons fetcher
## See details at: http://wiki.openstreetmap.org/wiki/Nominatim
## Made by: D.Kisler <admin@dkisler.de>
osm_polyFetcher <- function(address = NULL, n_results = 5)
{
  if(suppressWarnings(is.null(address)))
    return(data.frame())
  tryCatch(
    d <- fromJSON( 
      paste0(gsub('\\@addr\\@', gsub('\\s+', '\\%20', address), 
                  'http://nominatim.openstreetmap.org/search/@addr@?format=jsonv2&addressdetails=0&limit='), n_results, '&polygon_text=1'), flatten = F
    ), error = function(c) return(data.frame())
  )
  if(length(d) == 0) return(data.frame())
  #filter polygons and 
  d %<>% filter(grepl("polygon", geotext, ignore.case = T))
  return(d)
}