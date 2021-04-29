# This function corrects tree cover values which are smaller than 0 and larger than 100

Correct_TC <- function(tree_cover){
  tree_cover[tree_cover < 0] <- 0
  tree_cover[tree_cover > 100] <- 100
  return(tree_cover)
}