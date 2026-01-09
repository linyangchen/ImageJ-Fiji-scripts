//================================
//Model script for automation, looping and function
//Lin Yangchen
//NUS Centre for Bioimaging Sciences
//3 December 2025
//================================


//NOTES FOR THE USER

//For all images in a folder,
//does x, y and z
//saves results in csv
//and outputs jpeg for presentation

//Before using this code,
//if your images are in commercial format e.g. oir/czi/lif,
//disable file open dialogue popup by going to
//Plugins --> Bio-Formats --> Bio-Formats Plugins Configuration,
//going to Formats tab, selecting the format in the list
//and checking Windowless.

//Install XXX plugin before using this script



//==================================
//USER SETTINGS

//image file format
format = ".tif";


//size range for Analyze particles
min_particle_size = "5";
max_particle_size = "Infinity";


//Specify folder path with slash at the end

//If using Windows
dir = "C:/Users/yangchen/Desktop/test/";

//If using Mac
//dir = "/Users/yangchen/Desktop/Fiji_workshop/";



//======================================================

//MAIN SCRIPT



//get the list of files in the folder
filelist = getFileList(dir);

//do not display images during execution
setBatchMode(true);

//file counter for tracking progress
count = 0;

//no. of rows in Results table (0 at the beginning)
nrow = 0;

for (i = 0; i < filelist.length; i++)
{
	
	//only process image files
	if (endsWith(filelist[i], format))
	{
		
	//track progress
	count = count + 1;
	print("processing file " + count);
		
	//open file
	open(dir + filelist[i]);


	//===================
	//processing/analysis
	//===================		


	run("Z Project...", "projection=[Max Intensity]");
	run("Duplicate...", "duplicate channels=4");
	rename("nuclei");
	run("Duplicate...", " ");
	rename("mask");


	segcount(min_particle_size, max_particle_size);


	//================================
	//add file names to Results table
	
	selectWindow("Results");

	if (i == 0){
		//create new column for file names
		Table.setColumn("File");
	}

	//add file name to new rows
	for (j = nrow; j < Table.size; j++){
		Table.set("File", j, filelist[i]);
	}

	//update value of nrow
	nrow = Table.size;

	//============================
	
	

	//export image
	selectImage("nuclei");
	run("RGB Color");
	run("Scale Bar...", "width=5 height=5 horizontal bold overlay");
	saveAs("Jpeg", dir + File.getNameWithoutExtension(filelist[i]) + "_nuclei.jpg");

	//close all image windows (tables remain open)
	close("*");

	//clear memory
	run("Collect Garbage");

	} //end of if statement
} //end of for loop



//======================
//save data

selectWindow("Summary");
saveAs("Results", dir + "Summary.csv");
run("Close");

selectWindow("Results");
saveAs("Results", dir + "Results.csv");
run("Close");



print("job finished");



//======================================================

//PREDEFINED COMMANDS

function segcount(minsize, maxsize){
	
	//smooth out noise
	run("Median...", "radius=2");
	
	//segmentation
	setAutoThreshold("Default dark 16-bit no-reset");
	setOption("BlackBackground", true);
	run("Convert to Mask");
	run("Fill Holes");

	//count nuclei
	run("Analyze Particles...", "size=" + minsize + "-" + maxsize + " display exclude summarize");
	
}