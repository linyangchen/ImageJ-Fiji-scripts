
//===============================================
// batch auto threshold and segment micrographs of pits in postage stamp paper coatings
// record position coordinates, area, circularity etc.
// Lin Yangchen
// 29 June 2023
//===============================================




//===============================================
// User settings
//===============================================

rootdir = "/Users/yangchen/philately/paper/topo/microscopy/pitanalysis/";
input = "/Users/yangchen/philately/paper/topo/microscopy/pitanalysis/images/";
output = "/Users/yangchen/philately/paper/topo/microscopy/pitanalysis/segmented/";

//image scale in pixels per micron
scale = 1.38;

//median filter radius (pixels)
rad = 5;

//===============================================


setBatchMode(true); //do not display images during execution

filelist = getFileList(input);

for (i = 0; i < filelist.length; i++)
{
		count = i + 1;
		print("processing image " + count + " of " + filelist.length);
		
		open(input + filelist[i]);
		rename(filelist[i]);
		
		run("Duplicate...", "title=duplicate");
		
		run("8-bit");
		
		run("Subtract Background...", "rolling=50");
		
		run("Enhance Contrast", "saturated=0.35");
		
		run("Median...", "radius="+rad);
		
		run("Duplicate...", "title="+filelist[i]+"_copy");
		
		run("Auto Threshold", "method=RenyiEntropy white");
		
		run("Invert");
		run("Fill Holes");
		run("Watershed");
		
		run("Set Measurements...", "area center shape display redirect=None decimal=3");
		
		//analyze particles
		run("Analyze Particles...", "size=250-5000 circularity=0.75-1.00 show=Nothing display exclude summarize add");
		roiManager("Show None");
		
		
		
		
		selectWindow("duplicate");
		roiManager("Show All without labels");
		
		RoiManager.setGroup(0);
		RoiManager.setPosition(0);
		roiManager("Set Color", "red");
		roiManager("Set Line Width", 5);
		
		run("Flatten");
		
		selectWindow("duplicate");
		run("Close");
		
		
		
		
		selectWindow(filelist[i]);
		run("Set Scale...", "distance="+scale+" known=1 unit=micron");
		run("Scale Bar...", "width=100 thickness=5 font=50 color=White background=Black location=[Lower Right] horizontal");
		
		
		

		run("Images to Stack");
		//run("Make Substack...", "slices=1,3,2");
		run("Make Montage...", "columns=3 rows=1 scale=1");
		saveAs("Jpeg", output + filelist[i] + "_segmented.jpg");

	
		run("Close All");
		roiManager("Delete");
		run("Collect Garbage");
}

saveAs("Results", rootdir + "data.csv");
selectWindow("Results");
run("Close");

selectWindow("Summary");
saveAs("Results", rootdir + "summary.csv");
run("Close");

print("job done");