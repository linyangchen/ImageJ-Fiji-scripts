
//===============================================
// counts spots in each nucleus on all images in folder
// Lin Yangchen
// NUS Centre for Bioimaging Sciences
// 20 May 2023
//===============================================

//all images must be in the same file format and placed in a folder with no other files
//your image file names should not have any spaces
//set Bio-Formats Plugins Configuration for your file format to windowless
//assumes your image is 16-bit




//===============================================
// User settings
//===============================================



//change input and output to your own folder paths
//the folder paths should have the slash at the end

//Windows example
//you have to use forward slash as shown below, not the usual backslash
input = "C:/Users/yangchen/Desktop/nishadi/images/";
output = "C:/Users/yangchen/Desktop/nishadi/results/";

//Mac example
//input = "/Users/yangchen/microscopy/CBIS/scripting/Fiji/focusnucleus/images/";
//output = "/Users/yangchen/microscopy/CBIS/scripting/Fiji/focusnucleus/results/";



//which channels contain the nucleus and spot signals
nucleus_chn = 3;
spot_chn = 1;

//median filter radius (pixels)
rad = 2;

//prominence of spots for finding maxima
prominence = 4000;


//===============================================







setBatchMode(true); //do not display images during execution

filelist = getFileList(input);

//table for storing mean spots per nucleus of each image
Table.create("meancounts");

for (i = 0; i < filelist.length; i++)
{
		run("Clear Results");
		
		print("processing " + filelist[i]);
		
		open(input + filelist[i]);
		rename("orig");

		run("Duplicate...", "title=nuclei duplicate channels="+nucleus_chn);
		run("Z Project...", "projection=[Max Intensity]");
		run("Duplicate...", "title=x"); //for segmentation

		//auto brightness and contrast
		run("Enhance Contrast", "saturated=0.35");

		//smooth out noise
		run("Median...", "radius="+rad);

		//threshold and count nuclei
		setAutoThreshold("Default dark no-reset");
		setOption("BlackBackground", false);
		run("Convert to Mask");
		run("Fill Holes"); run("Watershed");
		run("Analyze Particles...", "size=100-300 circularity=0.50-1.00 show=Outlines exclude add");
		
		//switch to spot channel
		selectWindow("orig");
		run("Duplicate...", "title=spots duplicate channels="+spot_chn);
		run("Z Project...", "projection=[Max Intensity]");

		//find intensity peaks (spots)
		//represent each peak by a single pixel of intensity 255 (8-bit maximum)
		//get sum of spot pixel intensities in each nucleus
		run("Set Measurements...", "integrated redirect=None decimal=3");
		run("Find Maxima...", "prominence=4000 exclude output=[Single Points]");
		run("ROI Manager...");
		roiManager("Measure");
		
		//divide total spot pixels in each nucleus by 255 to get number of spots
		for (row = 0; row < nResults; row++)
		{
			spotcount = getResult("RawIntDen", row)/255;
    		setResult("spotcount", row, spotcount);
		}
		counts = Table.getColumn("spotcount"); //for mean calculation later
		saveAs("Results", output + filelist[i] + "_spotcounts.csv");
		selectWindow("Results"); run("Close");
		
		//mean spots per nucleus
		Array.getStatistics(counts, min, max, mean);
		selectWindow("meancounts");
		Table.set("image", i, filelist[i]);
		Table.set("meancount", i, mean);
		
		//save nucleus outlines with white spot pixels overlaid on spots
		//for ground truthing
		selectWindow("MAX_spots Maxima");
		run("Invert LUT"); run("16-bit");
		run("Merge Channels...", "c2=MAX_spots c3=MAX_nuclei c4=[MAX_spots Maxima] create");
		roiManager("Show All"); run("Flatten");
		saveAs("Tiff", output + filelist[i] + "_nuclei.tif");

		roiManager("Delete");
		run("Collect Garbage");
}

//save table of mean counts for all images
selectWindow("meancounts");
saveAs("Results", output + "meancounts.csv");
//selectWindow("meancounts.csv"); run("Close");

print("job done");