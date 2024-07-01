//================================
//Script to do what
//Author
//Affiliation
//Date
//================================

//Notes for the user




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

	if (endsWith(filelist[i], ".TIF") || endsWith(filelist[i], ".tif"))
	{



	count = count + 1;
	print("processing image " + count + " of " + filelist.length);

	open(dir + filelist[i]);


	//processing/analysis code


	run("Collect Garbage");

	}

}



selectWindow("Results");
saveAs("Results", dir + "data.csv");

print("job finished");