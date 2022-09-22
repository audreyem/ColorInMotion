## Audrey E Miller and Benedict G Hogan 2022
# This code simply captures a view of the model in Metashape. 

# This was used to help generate figures and
# to make reference images that showed where the patch ROIs were located on each model. 
# This helped the authors match the general area of the ROI on the physical specimen 
# when taking samples using the spectrophotometer.

# define path, take reference image
search_path = Metashape.app.getSaveFileName("Specify where to save screenshot")
image = Metashape.app.model_view.captureView(width = 4000, height = 4000, transparent = True, hide_items = True)
image.save(search_path)