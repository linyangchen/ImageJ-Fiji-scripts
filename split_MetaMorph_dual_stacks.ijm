
//===============================================
// Lin Yangchen
// NUS Centre for Bioimaging Sciences
// 29 June 2023
//===============================================


//takes a folder containing one or more subfolders of tif and nd files
//there should be only one level of subfolders
//a subfolder can contain multiple nd datasets
//folder and file names should not contain spaces or special characters

//splits left channel from right and merges them into hyperstack
//currently works only on images of 2400 x 1200 pixels
//left side becomes channel 1, right side channel 2
//currently does not assign LUTs according to metadata; please set LUTs yourself
//leaves original files untouched


//===============================================






input = getDirectory("choose folder");

//replace backslashes with forward slashes (if using Windows)
input = replace(input, "\\", "/");


setBatchMode(true); //do not display images during execution



subdirs = getFileList(input);

for (j = 0; j < subdirs.length; j++)
{

output = input + subdirs[j];
filelist = getFileList(output);

count = 0;

for (i = 0; i < filelist.length; i++)
{
		if (endsWith(filelist[i], ".TIF") || endsWith(filelist[i], ".tif"))
		{
		
			count = count + 1;
			print("processing image " + count + " in /" + subdirs[j] + " subfolder");
		
			open(output + filelist[i]);
			name = File.nameWithoutExtension;
		
			rename("duplicate1");
        	run("Duplicate...", "title=duplicate2 duplicate");
            
        	makeRectangle(0, 0, 1200, 1200); //crop left half
        	run("Crop");
			
        	selectWindow("duplicate1");
        	
        	makeRectangle(1200, 0, 1200, 1200); //crop right half
        	run("Crop");
			
			
			//merge channels
			run("Merge Channels...", "c1=duplicate2 c2=duplicate1 create");
			saveAs("Tiff", output + "merged_" + filelist[i]);


			run("Close All");
			run("Collect Garbage");

		}
		
		
		
} //end of file loop

} //end of subdirectory loop


print("job done");
