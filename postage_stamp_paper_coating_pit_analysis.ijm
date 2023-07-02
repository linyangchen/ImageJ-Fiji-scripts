
//===============================================
// batch auto threshold and segment micrographs of pits in postage stamp paper coatings
// record position coordinates, area, circularity etc.
// https://www.linyangchen.com/De-La-Rue-chalky-paper-coating-pit
// Lin Yangchen
// 2 July 2023
//===============================================


//requires LoG 3D plugin http://bigwww.epfl.ch/sage/soft/LoG3D/


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



filelist = getFileList(input);

for (i = 0; i < filelist.length; i++)
{
		count = i + 1;
		print("processing image " + count + " of " + filelist.length);
		
		open(input + filelist[i]);
		rename(filelist[i]);
		
		




		//=================

		//Preprocessing and thresholding


		
		//METHOD 1 (rolling ball background subtraction, median filter)
		
		//run("Duplicate...", "title=duplicate");
		//run("8-bit");
		//run("Subtract Background...", "rolling=50");
		//run("Enhance Contrast", "saturated=0.35");
		//run("Median...", "radius="+rad);
		//run("Duplicate...", "title="+filelist[i]+"_copy");
		//run("Auto Threshold", "method=RenyiEntropy white");
		
		
		
		//METHOD 2 (Laplacian of Gaussian)
		
		run("Duplicate...", "title=bw");
		run("16-bit");
		
		print(" - running Laplacian of Gaussian");
		run("LoG 3D", "sigmax=14 sigmay=14 displaykernel=0");
		wait(5000);
		rename("duplicate");
		run("16-bit"); run("Invert");
		run("Duplicate...", "title="+filelist[i]+"_copy");
		
		print(" - running auto threshold");
		//run("Auto Threshold", "method=RenyiEntropy white"); 
		run("Auto Threshold", "method=Default white");
		wait(10000);

		selectWindow("bw");
		run("Close");
		
		
		//=================




		run("Invert");
		run("Fill Holes");
		//run("Watershed");
		
		
		
		run("Set Measurements...", "area center shape display redirect="+filelist[i]+" decimal=3");
		
		
		print(" - analyzing particles");
		run("Analyze Particles...", "size=750-10000 circularity=0.85-1.00 show=Nothing display exclude summarize add");
		roiManager("Show None");
		
		
		
		
		selectWindow("duplicate");
		roiManager("Show All");
		//roiManager("Show All without labels");
		
		//change colour and thickness of outlines
		RoiManager.setGroup(0);
		RoiManager.setPosition(0);
		roiManager("Set Color", "yellow");
		roiManager("Set Line Width", 3);
		
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

selectWindow("Results");
saveAs("Results", rootdir + "data.csv");
run("Close");

selectWindow("Summary");
saveAs("Results", rootdir + "summary.csv");
run("Close");

selectWindow("ROI Manager");
run("Close");

print("job done");
