//================================
//Script to save time points of multichannel Z-stack
//as separate files
//Lin Yangchen
//NUS Centre for Bioimaging Sciences
//1 July 2024
//================================


//entire directory path and file names should have no spaces or special characters in them
//folder should contain only the images to be processed and no other files
//folder should not contain subfolders





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

	count = count + 1;
	print("processing " + filelist[i] + " (dataset " + count + " of " + filelist.length + ")");
	
	open(dir + filelist[i]);
	
	
	//how many time points are there?
	Stack.getDimensions(width, height, channels, slices, frames);
	
	//create new folder to contain the separated time points
	filename = File.nameWithoutExtension;
	dest = dir + filename + "_separated/";
	File.makeDirectory(dest);
	
	timecount = 0;
	for (j = 1; j <= frames; j++)
	{
		timecount = timecount + 1;
		print("processing time point " + timecount + " of " + frames + " in " + filelist[i]);
		
		selectImage(filelist[i]);
		
		run("Duplicate...", "duplicate frames=" + j);
		saveAs("Tiff", dest + filename + j);
		
		run("Collect Garbage");
	}
}


print("job finished");