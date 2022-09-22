/*
_______________________________________________________________________

	Title: Batch apply ROImasks
	Author: Audrey E Miller and Benedict G Hogan
	Date: 09/03/2020
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code sequentially loads 2D multispectral images, converts them to cone-catches, and applies an ROI masks generated in Metashape. These masks correspond
to the 3D multispectral texture ROI generated in Metashape. There will be a mask of the ROI for every 2D multispectral image in which it appears. The result will be cone catch values for multiple 
2D multispectral images. either one (main text analysis) or all of these qCatch values (Supplementary Figures 4-6) can be compared to cone catch values estimated from the same area on the 3D multispectral texture to verify
color retention in the 3D multispectral modeling workflow. This code is used in the "Verifying the accuracy of color information from the multispectral models" section of "Color in motion: Generating 3D 
multispectral models to study dynamic visual signals in animals".

Instructions:
''''''''''''''''''''''''''''''''''''''''
Select folder containing 2D multispectral images, then select a folder containing one binary ROI mask (named identically to the 2D multispectral
image except suffixed '_mask.png', select cone catch model, and allow batch processing to measure cone catch in each image's ROI.
_________________________________________________________________________
*/

// List mspecs
imageDIR = getDirectory("Select folder containing multispectral images");
fileList=getFileList(imageDIR);
mspecList=newArray();
for(i=0; i<fileList.length; i++){ // list only mspec files
	if(endsWith(fileList[i], ".mspec")==1)
		mspecList = Array.concat(mspecList, fileList[i]);
}

// Where are ROI masks for each/most of the mspecs
maskDIR = getDirectory("Select folder containing binary masks for the multispectral images");
maskList=getFileList(maskDIR);

// From MICA, get all the models so we can choose just once
modelPath = getDirectory("plugins")+"Cone Models";
modelList=getFileList(modelPath);
modelNames = newArray("None");
for(i=0; i<modelList.length; i++){
	if(endsWith(modelList[i], ".class")==1 && modelList[i] != "Human_Luminance_32bit.class")
		modelNames = Array.concat(modelNames,replace(modelList[i],".class",""));
	if(endsWith(modelList[i], ".CLASS")==1 && modelList[i] != "Human_Luminance_32bit.class")
		modelNames = Array.concat(modelNames,replace(modelList[i],".CLASS",""));
}

// Select a cone catch model
Dialog.create("Image Processing Settings");
	Dialog.addMessage("Select the visual system to use:");
	Dialog.addChoice("Model", modelNames);
Dialog.show();
visualSystem = Dialog.getChoice();
visualSystem = replace(visualSystem, "_", " ");

// LOOP through
startNumber = 0;
for(i=startNumber; i<mspecList.length; i++){

	print("\\Update3:Processing Image " + (i+1) + " of " + mspecList.length);

	while(roiManager("count") > 0){ // clear ROIs
		roiManager("select", 0);
		roiManager("Delete");
	}
	
	// LOAD MULTISPECTRAL IMAGE
	imageString = "select=[" + imageDIR + mspecList[i] + "]";
	run("Create Stack from Config File", imageString);
	run("Normalise & Align Multispectral Stack", "normalise curve=[Straight Line] align");
	setSlice(1);
	
	// APPLY CONE CATCH
	origImage = getImageID();
	run(visualSystem);
	coneImage = getImageID();
	selectImage(origImage);
	close(); // close original image
	afterImage = getImageID();
	
	// GET MASK
	name = File.getNameWithoutExtension(mspecList[i]);
	maskname = maskDIR + name + "_mask.png";
	print(maskname);
	if(File.exists(maskname)){
		print('Found mask');
	} else {
		print('Not found');
	}
	
	// Open & Apply mask
	open(maskname);
	// Binarize the mask
	setOption("BlackBackground", false);
	run("Convert to Mask");
	run("Create Selection");
	close();

	// Apply that selection here
	selectImage(afterImage);
	run("Restore Selection");

	// Save as roi, rename ROI to the name of the mask
	roiManager("Add");
	roiManager("Select", roiManager("count")-1);
	roiManager("Rename", name);
	
	run("Measure ROIs");
	
	selectImage(afterImage);
	close();
}
	





