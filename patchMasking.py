## Audrey E Miller and Benedict G Hogan 2022

# This script automates the process of
# generating binary masks for all images, as well as the
# texture of the model indicating a region of interest on the model.
# These ROIs are then imported into ImageJ using the "Bach_apply_roimasks"
# macro (for the 2D multispectral images) or the "Load_Multiispectral_Texture" 
# macro (for the 3D multispectral texture).

# To use this, open your file and go to chunk 1, model 1, make a selection
# of polygons. Then run the script. It should do the rest!

# NOTE: This comes after copyChunkChangePaths.py script.
# That means we expect only one model per chunk by this point.

# For whatever reason, you if you get an error from metashape that some files cannot be found. Reopen the restart metashape, and reopen
# the original metashape file for it.

# Equally, will fail silently (metashape crash) if animation frames are present

########## Delete unselected model vertexes, then import masks from the model - this generates ROIs for each image, 
# then replace images with the masks, render texture like that - this generates an ROI for the model texture for the corresponding points

import Metashape
import os

doc = Metashape.app.document
chunk = doc.chunks[0]

# define path to output ROIs for all images
search_path = Metashape.app.getExistingDirectory("Specify where to save photograph masks")

# take reference image
image = Metashape.app.model_view.captureView(width = 1200, height = 900, transparent = False, hide_items = True)
image.save(search_path + "_ref.png")

# copy a chunk for later use
newchunk = chunk.copy()
chunk = doc.chunks[0]
 
# invert the face selection, then remove selected
model = chunk.models[0]
for face in model.faces:
    if face.selected == True:
        face.selected = False
    else:
        face.selected = True
model.removeSelection()
print('Removed unselected faces')

# generate masks from the cropped model
chunk.generateMasks(masking_mode = Metashape.MaskingMode.MaskingModeModel)
print('Generated masks for selected faces')

# export the masks (NOTE: failure here may be due to presence of animation frames)
task = Metashape.Tasks.ExportMasks()
task.cameras = [camera.key for camera in chunk.cameras]
task.path = search_path + "/" + "{filename}_mask.png"
task.apply(chunk)
    
print('Finished exporting masks for selected faces')

# go back to the saved chunk (with unmanipulated model)
chunk = newchunk

########## Apply masks as textures

print('Replacing photos with masks for each camera')
for camera in chunk.cameras: # for each camera in chunk
    print(camera)

    if camera.label!='': # unlabelled cameras are for animation so skip
    
        if camera.enabled==True:
            
            # get old camera filename
            oldpath = camera.photo.path
            oldname = os.path.split(oldpath)[1] 
            print(type(camera))
            
            # generate new camera filename
            newpath = search_path + '/' + os.path.splitext(oldname)[0] + '_' + 'mask.png' 
            
            # print(newpath)
            
            # does that file exist?
            exists = os.path.isfile(newpath)
            
            if exists:
                print('Found Path!')
                # apply new path and open image
                photo = camera.photo.copy()
                photo.path = newpath
                camera.photo = photo
                camera.open(newpath)
            else:
                print('The following file not found so disabling camera')
                print(newpath)
                camera.enabled = False
                
        else:
            print('Camera was disabled')
    else: 
        # print('Camera was an animation camera')
        camera.enabled = False  
print('Finished applying masks to photos')


########## Generate and save JUST the texture out
## IMPORTANT NOTE: Do not save this version of the model! 
print('Building a binary texture for the mask')
# export the masks
chunk.buildTexture(blending_mode=Metashape.MosaicBlending, ghosting_filter=True, fill_holes=True, texture_size=8192) # not clear if on or off is best here
na = os.path.basename(search_path)
model = chunk.model
model.saveTexture(search_path + ".tif")

########## Exit out of Metashape WITHOUT saving!

print('Finished exporting masks. Close Metashape WITHOUT SAVING!')

