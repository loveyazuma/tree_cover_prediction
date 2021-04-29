# This function calculates the average tree cover percent for each land cover classes
calc_TreeCover_byLandCover <- function(classPoly, TreeCover){
  classPoly$Code <- as.numeric(classPoly$Class) #convert to integer by using the as.numeric() function

    # Convert training data to the same type with raster to train the raster data
  # Assign 'Code' values to raster cells (where they overlap)
  classes <- rasterize(classPoly, TreeCover, field='Code', progress="text") 
 
   # Create raster that representing the training pixels
  TC_mask <- mask(TreeCover, classes) 
  
  # Zonal statistics per class 
  TC_zonal <- zonal(TC_mask, classes, fun = mean) 
  rownames(TC_zonal) <- levels(classPoly$Class)
  TC_zonal_value <- TC_zonal[ ,'value']
  return(TC_zonal_value)
}