/*
_______________________________________________________________________

	Title: Load Multispectral Texture
	Author: Audrey E Miller and Benedict G Hogan
	Date: 09/03/2020
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code loads multispectral textures as an image stack from their .tiff color channel files. 
It will then ask whether you want to run a cone catch model on the mutlispectral texture to convert the stack 
using a cone mapping model. After you convert the mulitpspectral texture using your desired cone mapping model, 
you will be asked if you want to import masks generated from Metashape to sample certain patches. This code is used in
"Steps 5a: Extracting color data directly from model textures" and the "Verifying the accuracy of color information from the 
multispectral models" section of "Color in motion: Generating 3D multispectral models to study dynamic visual signals in animals". 

Instructions:
''''''''''''''''''''''''''''''''''''''''
Run the script and select all .tiff color channel files. Answer the pop-up prompts to convert the texture to 
cone catch, import masks, and sample pixels from masked regions of the texture.

_________________________________________________________________________
*/

//SELECT DIR WITH TEXs
imageDIR = getDirectory("Select folder containing multispectral images");

//MAKE LIST OF ALL NEEDED TEXs IN CORRECT ORDER
imOrder = newArray("r.tif","g.tif","b.tif","uvr.tif","uvb.tif");

for(i=0; i<imOrder.length; i++) { // list only .tif files
	if(matches(imOrder[i], "Chunk 1.tif")==0){
		// LOAD COLOR CHANNEL TEXTURES
		open(imageDIR+imOrder[i]);
		// CONVERT TO 32 BIT AND SCALE PIXEL DEPTH TO 0 TO 100
		run("32-bit");
		run("Divide...", "value=655.35");
		setMinAndMax(0, 100);
		}
}
// IMAGES TO STACK
stackString = "name=" + "Multispectral Texture" + " title=[] use";
run("Images to Stack", stackString);

print("Ready to convert to cone catch");	

// SAVE MULTICHANNEL TIFF
//outDIR = replace(imageDIR,"\meta\tex","\imagej");
//if(File.isDirectory(outDIR)==0){
	//File.makeDirectory(outDIR)
//}

// This saves the multispectral texture as a multi-channel tiff. This is not needed for the rest of the workflow, so this step can be ommitted.
// output = imageDIR + "multitex.tif";
// saveAs("Tiff", output);
// print("tiff saved");

// Run jolyon's cone catch 
conecatch_question = getBoolean("Do you want to apply a cone catch model?");
if(conecatch_question==1){
	run("Convert to Cone Catch");

	// Now ask for binary ROI masks made in Metashape
	// This currently works one ROI at a time, but could be editied to process whole ROI folders
	// dir = getDirectory("What ROI mask folder to process '../dat/XX/meta/roi_masks/XX/'");
	// list = getFileList(dir);
	
	masking_question = getBoolean("Do you want to import masks?");

	if(masking_question==1){
		// Now it's cone catch, get info for swapping
		cc_window = getTitle();
			
		notdone = 1;

		while (notdone==1) {

			// Select the roi mask you want to use
			list = File.openDialog("Select a Texture ROI mask './dat/XX/meta/roi_masks/XX.tif'");
			open(list);

			// Binarize the mask
			setOption("BlackBackground", false);
			run("Convert to Mask");
			
			run("Create Selection");

			// Apply that selection here
			selectWindow(cc_window);
			run("Restore Selection");

			// Save as roi, rename ROI to the name of the mask
			roiManager("Add");
			roiManager("Select", roiManager("count")-1);
			roiManager("Rename", File.getNameWithoutExtension(list) + "_tex");
			
			notdone = getBoolean("Do you have any more masks to add?");
			
		}

		// Measure slices
		selectWindow(cc_window);
		run("Measure ROIs");
		
		// Ask user for where to save - prompt them to include specimen info 
		savplace = File.openDialog("Select a place to save results. Include specimen details.");
		saveAs("Results", savplace);
		
	}
	
}