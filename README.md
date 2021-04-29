## Tree cover prediction using Linear regression and RF regression
Tree cover products represent a canopy closure for high vegetation. It is encoded as a precentage (0-100) indicating different canopy closure levels. Tree cover products [e.g. by University of Maryland](https://earthenginepartners.appspot.com/science-2013-global-forest) have a variaty of uses: generating forest masks, identifying dense forested areas, forest biomass estimation, understanding forest structure, and so on. 
The aim of this analysis is to map tree percent cover of Gewata region using random forest regression and linear regression. It is important to note that the same principle as classification apply here. The only difference is that the response variable is continuous, not categorical.  Since the analysis utilizes two regression algorithms, it would be interesting to see the difference on the results. This can be achieved by simply subtracting the two results. Also, the analysis show how the tree percent covers vary among different land cover types. 


### Details
- The Landsat data can be found [here](https://www.dropbox.com/s/cv1de2fmy855wpy/data.zip?dl=1)


### Processes
- The data was downloaded from the dropbox into the script
- 2 functions were defined and used for analyzing the results of the regressions
- The two predictions were visualized as maps and saved as `.png` files
- Identified the three most important explanatory variables (bands) for tree cover prediction using Random Forest regression
- The resulting difference map was visulaized, and saved as a `.png` file
- The tree percent covers were visualized for different land cover types for each of the results and saved as a `.png` file
