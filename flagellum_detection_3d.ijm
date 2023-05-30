
//===============================================
// LSM 5232 Fiji tutorial
// runs ridge detection on all images in folder
// Lin Yangchen
// NUS Centre for Bioimaging Sciences
// 7 May 2023
//===============================================


//requires ridge detection plugin to be installed (Biomedgroup update site)
//all images must be in the same file format and placed in a folder with no other files
//your image file names should not have any spaces
//set Bio-Formats Plugins Configuration for your file format to windowless


//===============================================
// User settings
//===============================================



//change input and output to your own folder paths
//the folder paths should have the slash at the end

//Windows example
//you have to use forward slash as shown below, not the usual backslash
//input = "C:/Users/yangchen/Desktop/5232/images/";
//output = "C:/Users/yangchen/Desktop/5232/results/";

//Mac example
input = "/Users/yangchen/microscopy/CBIS/scripting/Fiji/5232/images/";
output = "/Users/yangchen/microscopy/CBIS/scripting/Fiji/5232/results/";



//channel for ridge detection
chn = 1;

//===============================================





setBatchMode(true); //do not display images during execution

filelist = getFileList(input);

for (i = 0; i < filelist.length; i++)
{
		run("Clear Results");
		
		print("processing " + filelist[i]);
		open(input + filelist[i]);

		run("Duplicate...", "title=ridges duplicate channels="+chn);
		run("8-bit");
		
		run("Ridge Detection", "line_width=12 high_contrast=125 low_contrast=75 estimate_width displayresults make_binary method_for_overlap_resolution=SLOPE sigma=2 lower_threshold=0.17 upper_threshold=0.51 minimum_line_length=75 maximum=0 stack");
		
		
		//mean intensities of flagella
		run("Set Measurements...", "mean redirect=ridges decimal=3");
		run("Analyze Particles...", "display clear stack");
		
		//save mean intensities of flagella
		selectWindow("Results");
		saveAs("Results", output + filelist[i] + "_intensity.csv");
		
		//save outlines of flagella
		selectWindow("ridges");
		run("Flatten", "stack");
		saveAs("Tiff", output + filelist[i] + "_trace.tif");
		
		//save binary mask of flagella
		selectWindow("ridges Detected segments");
		saveAs("Tiff", output + filelist[i] + "_binary.tif");

		//save lengths and widths of flagella
		selectWindow("Summary");
		writeto = filelist[i] + "_lengthwidth.csv";
		saveAs("Results", output + writeto);
		selectWindow(writeto); run("Close");
		run("Collect Garbage");
}

selectWindow("Junctions"); run("Close");
selectWindow("Results"); run("Close");

print("job done");