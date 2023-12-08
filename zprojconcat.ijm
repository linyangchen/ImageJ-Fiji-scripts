//====================================================================
//====================================================================
//Maximal-intensity Z-project each time point and combine the projected images into a time stack

//Lin Yangchen
//Centre for Bioimaging Sciences, National University of Singapore
//8 December 2023
//====================================================================
//====================================================================

//prompts you to select the folder containing the images
dir = getDirectory("choose folder");

//replace backslashes with forward slashes (if using Windows)
dir = replace(dir, "\\", "/");

setBatchMode(true); //do not display images during execution

//get the list of files in the folder
filelist = getFileList(dir);

//open each file and Z-project it
count = 1;
for (i = 0; i < filelist.length; i++)
{

	print("processing " + filelist[i] + " (" + count + " of " + filelist.length + ")");

	//open the file
	run("Bio-Formats Windowless Importer", "open=" + dir + filelist[i]);
	newname = "stack" + count;
	rename(newname);

	run("Z Project...", "projection=[Max Intensity]");

	//close original image
	selectImage(newname);
	close();
	
	//free up memory
	run("Collect Garbage");

	count = count + 1;

}

//combine images into time series
print("combining images into time series");
run("Concatenate...", "all_open title=_timeseries open");
saveAs("Tiff", dir + "_timeseries.tif");
close();
print("finished");
