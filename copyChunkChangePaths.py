### Audrey E Miller and Benedict G Hogan 2022

## This script copies the original metashape chunk N times (this code currently works with 6 channels: r, g, b, uvr, uvb. If your images have a 
## different number of channels you will need to edit the code). This code is used in "Step 4: Multispectral texture
## generation and refinement".

## The user can then generate and export textures for each of those tiff channels (retaining model uv ## mapping) through batch processing.

# NOTE: at this stage, we only want one model per chunk - in this step in the workflow, it should be the retopologised and re-uv'd one

import Metashape
import os

# Get dir of multispectral tiff versions of each image (generated in MICA)
search_path = Metashape.app.getExistingDirectory("Specify where to search for other tiff folders (dat/XXX/tiffs)")

# Option to cancel out
if not search_path:
	print("Script aborted")
	
# Actually save within the path defined
search_path=search_path+"/" 

# Get first chunk (RGB presentation image chunk)
basechunk=Metashape.app.document.chunks[0] 

# define number of loops, and labels for convenience
nchunks=6
chunklab=['r', 'g', 'b', 'uvr', 'uvb']

# define tiff directories and camera independent channels
splittiffdirs=['R/', 'G/', 'B/', 'UVR/', 'UVB/']
channelstr=['visR','visG','visB','uvR','uvB']

# filepath to export each texture to
save_path = Metashape.app.getExistingDirectory("Specify project filename for texures (dat/XXX/meta/tex):") 

# another chance to cancel out
if not save_path:
	print("Script aborted")

for i in range(1,nchunks): # for all chunks after the first chunk up to nchunks
	print(i)

	basechunk.copy() # copy the base chunk
	curchunk = Metashape.app.document.chunks[i] # get the current chunk
	curchunk.label = chunklab[i-1] # get appropriate label
	
	for camera in curchunk.cameras: # for each camera in chunk
	
		if camera.label!='': # unlabelled cameras are for animation so skip
        
			# get old camera filename
			oldpath = camera.photo.path
			oldname = os.path.split(oldpath)[1] 
			print(type(camera))
			
			# generate new camera filename
			newpath = search_path + splittiffdirs[i-1] + os.path.splitext(oldname)[0] + '_' + channelstr[i-1] + '.tif' 
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
			# print('Camera was an animation camera')
			camera.enabled = False

	# then re-generate textures for the chunk, given new photographs
	curchunk.buildTexture(blending_mode=Metashape.MosaicBlending, texture_size=8192, fill_holes=True, ghosting_filter=True)
    
# Set Image Compression to No Tiff Compression for saving
compression = Metashape.ImageCompression()
compression.tiff_compression=Metashape.ImageCompression.TiffCompressionNone

# Save the texture from each chunk as a 16Bit RGB image
for chunk in Metashape.app.document.chunks:
    model = chunk.model
    if chunk == Metashape.app.document.chunks[0]: # if we're working on the RGB chunk, save RGB output texture
        image  = model.getActiveTexture().image().convert('RGB','U16')
    else: # otherwise, save a 1 channel grayscale
        image  = model.getActiveTexture().image().convert('R','U16')
    image.save(save_path + "/" + chunk.label  + ".tif",compression)
    
print('Script completed, see dat/XXX/meta/tex for final textures')