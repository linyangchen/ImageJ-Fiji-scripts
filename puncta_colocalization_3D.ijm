//====================================================================
//====================================================================
//3D overlap colocalization analysis

//Lin Yangchen
//Centre for Bioimaging Sciences, National University of Singapore
//13 October 2023
//====================================================================
//====================================================================


//takes a folder containing one or more subfolders
//there should be only one level of subfolders
//subfolder should contain only image files

//requires 3D ImageJ Suite plugin
//in Bio-Formats Plugins Configuration, set opening of your file format to windowless
//folder and file names should not have any spaces or special characters

//the following are saved in a folder with the same name as the image:
//3D ROIs of segmented objects (one file for each channel)
//3D measurements of segmented objects
//percent overlap of every object pair



//===========================
//user settings
//===========================

//before running the script, go to 3D Manager Options in the GUI
//and set the required measurements

//which channels for overlap analysis
chn = newArray(3,4);

//threshold intensity for each channel
thresh = newArray(10000,5000);

//===========================




dir = getDirectory("choose folder");

//replace backslashes with forward slashes (if using Windows)
dir = replace(dir, "\\", "/");




//setBatchMode(true); //do not display images during execution





subdirs = getFileList(dir);

for (j = 0; j < subdirs.length; j++)
{

input = dir + subdirs[j];
filelist = getFileList(input);

for (i = 0; i < filelist.length; i++)
{

	if (endsWith(filelist[i], "/")){} else //ignore subsubfolders
	{

	run("Clear Results");

	print("processing " + filelist[i] + " in /" + subdirs[j] + " subfolder");
	
	open(input + filelist[i]);
	
	filename = File.nameWithoutExtension;
	print(filename);
	output = input + filename + "_results/";
	File.makeDirectory(output);
	
	rename("orig");

	//duplicate the two channels
	run("Make Subset...", "channels="+chn[0]+","+chn[1]);
	rename("dup");
	
	
	//you can insert preprocessing steps here
	//e.g. median filter to smooth out noise


	//===========================
	//3D segmentation
	
	for (k = 0; k < 2; k++)
	{
		selectImage("dup");
		Stack.setChannel(k + 1);
		run("3D Simple Segmentation", "seeds=None low_threshold="+thresh[k]+" min_size=0 max_size=-1");
		
		selectImage("Bin");
		rename("Bin_ch" + chn[k]);
		
		selectImage("Seg");
		rename("Seg_ch" + chn[k]);
	}
	
	
	
	
	
	//================================
	//3D ROI Manager macro examples
	//https://imagejdocu.list.lu/plugin/stacks/3d_roi_manager/start
	
	run("3D Manager");

	selectImage("Seg_ch" + chn[1]); //second channel
	Ext.Manager3D_AddImage();
	Ext.Manager3D_Save(output + filename + "_ch" + chn[1] + "_roi.zip");
	
	Ext.Manager3D_Delete(); //delete (add again later)
	
	selectImage("Seg_ch" + chn[0]); //first channel
	Ext.Manager3D_AddImage();
	Ext.Manager3D_Save(output + filename + "_ch" + chn[0] + "_roi.zip");
	
	selectImage("Seg_ch" + chn[1]); //second channel
	Ext.Manager3D_AddImage();

	
	//object measurements e.g. size
	Ext.Manager3D_Measure();
	Ext.Manager3D_SaveResult("M", output + filename + ".csv");
	Ext.Manager3D_CloseResult("M");
	
	//percent overlap
	Ext.Manager3D_Coloc();
	Ext.Manager3D_SaveResult("C", output + filename + ".csv");
	Ext.Manager3D_CloseResult("C");


	Ext.Manager3D_Delete();
	
	run("Close All");
	run("Collect Garbage");

	} //end of if statement

} //end of file loop
} //end of subdirectory loop

Ext.Manager3D_Close();
print("job done");


