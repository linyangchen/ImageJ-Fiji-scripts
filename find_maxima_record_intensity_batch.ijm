//================================
//Find maxima, measure their intensities and return average and pointwise values
//Lin Yangchen
//NUS Centre for Bioimaging Sciences
//7 January 2026
//================================


//NOTES FOR THE USER

//Before using this code,
//disable czi file open dialogue popup by going to
//Plugins --> Bio-Formats --> Bio-Formats Plugins Configuration,
//going to Formats tab, selecting the format in the list and checking Windowless.






//==================================
//Function for finding maxima and recording their intensities in a channel
//chn should be the title of the split channel to process

function fmri(chn){
	
	selectImage(chn);
	run("Find Maxima...", "prominence=10 exclude output=[Single Points]");
	run("Set Measurements...", "mean redirect=" + chn + " decimal=2");
	run("Analyze Particles...", "display clear summarize");
	
}

//==================================



//prompts you to select the folder containing the images
dir = getDirectory("choose folder");

//replace backslashes with forward slashes (if using Windows)
dir = replace(dir, "\\", "/");

//get the list of files in the folder
filelist = getFileList(dir);



setBatchMode(true); //do not display images during execution


count = 0;

for (i = 0; i < filelist.length; i++)
{
	
	//only process czi files
	if (endsWith(filelist[i], ".czi"))
	{

	count = count + 1;
	print("processing file " + count + " of " + filelist.length);
	
	//open file
	open(dir + filelist[i]);


	//===================
	//processing/analysis
	//===================

	//each channel in its own window
	rename("orig");
	run("Duplicate...", "title=C1 duplicate channels=1");
	selectImage("orig");
	run("Duplicate...", "title=C3 duplicate channels=3");
	
	channels = newArray("C1", "C3");
	
	for (j = 0; j < channels.length; j++){
		
		//analyze image using function defined earlier
		fmri(channels[j]);
		
		if (i == 0 && j == 0){

			//create column for file names and channels in summary table
			selectWindow("Summary");
			Table.setColumn("File");
			Table.setColumn("Channel");
			
		}
		
		
		//add file name and channel to summary table
		selectWindow("Summary");
		Table.set("File", Table.size-1, filelist[i]);
		Table.set("Channel", Table.size-1, channels[j]);
		
		//create columns and add file name and channel to results table
		selectWindow("Results");
		Table.setColumn("File");
		Table.setColumn("Channel");
		for (k = 0; k < Table.size; k++){
			Table.set("File", k, filelist[i]);
			Table.set("Channel", k, channels[j]);
		}
		saveAs("Results", dir + "data_points_" + File.getNameWithoutExtension(filelist[i]) + "_" + channels[j] + ".csv");
		
	}

	//close all image windows
	close("*");
	
	//clear memory
	run("Collect Garbage");

	}
}



selectWindow("Summary");
saveAs("Results", dir + "data_summary.csv");

print("job finished");
