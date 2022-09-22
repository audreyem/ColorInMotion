/*
_______________________________________________________________________

	Title: Batch MSPEC to tiff camera channels
	Author: Audrey E Miller and Benedict G Hogan
	Date: 09/03/2020
.................................................................................................................

Description:
''''''''''''''''''''''''''''''''
This code sequentially loads multispectral images, and saves each image out as both a presentation image, and a set of tiff channels
for each camera independent color channel. This code is used in "Step 2: Multispectral image generation and processing" of 
"Color in motion: Generating 3D multispectral models to study dynamic visual signals in animals".  

Instructions:
''''''''''''''''''''''''''''''''''''''''
Select folder containing multispectral images, and select a suitable output folder. The latter will be populated with subfolders for 
each of the outputs described above.

_______________________________________________________________________
*/

setBatchMode(true);

// SELECT DIRECTORY WITH MSPECS
imageDIR = getDirectory("Select folder containing multispectral images");
outDIR = getDirectory("Select folder to place channel folders");

fileList=getFileList(imageDIR);

mspecList=newArray();

// MAKE CHANNEL FOLDERS
rDIR = outDIR + "R" + File.separator;
File.makeDirectory(rDIR);
gDIR = outDIR + "G" + File.separator;
File.makeDirectory(gDIR);	
bDIR = outDIR + "B" + File.separator;
File.makeDirectory(bDIR);	
uvrDIR = outDIR + "UVR" + File.separator;
File.makeDirectory(uvrDIR);	
uvbDIR = outDIR + "UVB" + File.separator;
File.makeDirectory(uvbDIR);	
rgbDIR = outDIR + "RGB" + File.separator;
File.makeDirectory(rgbDIR);	


// MAKE LIST OF MSPECS IN FOLDER	
for(i=0; i<fileList.length; i++) { // list only mspec files
	if(endsWith(fileList[i], ".mspec")==1)
		mspecList = Array.concat(mspecList, fileList[i]);
		
}

// START PROCESSING FOR ALL IMAGES
startNumber = 0;
for(j=startNumber; j<mspecList.length; j++){
	
	// LOAD MULTISPECTRAL IMAGE
	print("Loading image " + j+1 + " from " + mspecList.length);
	imageString = "select=[" + imageDIR + mspecList[j] + "] image=[Aligned Normalised 32-bit]";
	run(" Load Multispectral Image", imageString);
	mspecName = replace(mspecList[j], ".mspec","");
	print("Mspec loaded");
	
	// MAKE AND SAVE PRESENTATION IMAGE
	run("Make Presentation Image", "visible_r_normalised=Red visible_g_normalised=Green visible_b_normalised=Blue uv_b_normalised=Ignore uv_r_normalised=Ignore transform=[Square Root] convert");
	falseRGB = rgbDIR + mspecName;
	saveAs("Tiff", falseRGB);
	close();
	
	// SAVE INDIVIDUAL CHANNELS TO CORRECT FOLDER
	for(p=1; p<=5; p++){
		print("Saving slice " + p);
		setSlice(p);
		if (p==1){
			output = rDIR + mspecName + "_visR";	
		}
		if (p==2){
			output = gDIR + mspecName + "_visG";
		}
		if (p==3){
			output = bDIR + mspecName + "_visB";		
		}
		if (p==4){
			output = uvbDIR + mspecName + "_uvB";
		}
		if (p==5){
			output = uvrDIR + mspecName + "_uvR";
		}
		run("Duplicate...", "use");
		run("16-bit");
		saveAs("Tiff", output);
		close();
	}
	print("all tiffs saved");
	close("*");
}
print("Finished Processing");	

