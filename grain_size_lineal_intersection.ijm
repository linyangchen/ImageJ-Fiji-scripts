

//==============================================

//Preprocess grain image for colour contrast, add random intersects and
//output grey values along intersect for each colour channel

//Lin Yangchen
//Centre for Bioimaging Sciences
//National University of Singapore
//7 March 2023

//==============================================



//detailed use case:
//https://www.linyangchen.com/Singapore-organ-pipe-microscopy


//You may have to manually click and run the median filter at the desired radius before running this script.
//Otherwise the median filter will run with the default radius even if the radius is set to a different value in the script.





//===============================================================
//function to generate randomly positioned and oriented lines
//spanning height and width of rectangular image
//===============================================================

function randomline(height, width, nlines){

    apportion = nlines/2;
    dim1 = floor(apportion);
    dim2 = Math.ceil(apportion);



    for(i = 0; i < dim1; i++){
    
    	makeLine(
    		0,
    		round(random() * h),
    		w,
    		round(random() * h)
    	);

    	roiManager("Add");
    
    }
    
    
    for(i = 0; i < dim2; i++){
    
    	makeLine(
    		round(random() * w),
    		0,
    		round(random() * w),
    		h
    	);

    	roiManager("Add");
    
    }
}






//===============================================================
//function for extracting and saving profile data
//===============================================================

function extractprofile(input, output, overlays, filename, radius, scale){
    

    open(input+filename);
    
    
    
    //extract pixel dimensions
    h = getHeight;
    w = getWidth;



	//random intersections
    randomline(h, w, nlines);
    roiManager("Save", overlays + filename + "_intersects.zip");
    
	//lengths of intersections
    run("Clear Results");
    roiManager("multi-measure measure_all");
    saveAs("Results", overlays + filename + "_intersect_lengths.csv");
    



    
    run("Set Scale...", "distance=" + scale + " known=1 unit=micron");
	scalebarwidth = 100;
	scalebarthick = 2;
	scalebarfont = 24;


	//show intersects on micrograph
    roiManager("Show All with labels");
    run("Flatten");
    run("Scale Bar...", "width=" + scalebarwidth + " thickness=" + scalebarthick +
    " font=" + scalebarfont + " background=Black horizontal");
    saveAs("Jpeg", overlays + filename + ".jpg");


	
    
    //preprocessing
    selectImage(filename);
    run("Median...", "radius = rad");
    
    
    
    //show intersects on processed micrograph
    run("Flatten");
    run("Scale Bar...", "width=" + scalebarwidth + " thickness=" + scalebarthick +
    " font=" + scalebarfont + " background=Black horizontal");
    saveAs("Jpeg", overlays + "processed_" + filename + ".jpg");

	
    
    //extract and save profile data for each channel and each line

    colours = newArray("red", "green", "blue");
    selectWindow(filename);
    run("Split Channels");
    

    for(i = 0; i < colours.length; i++){
    
    	selectWindow(filename + " (" + colours[i] + ")");
    	run("Enhance Contrast", "saturated=0");
    	
    	for(j = 0; j < nlines; j++){
        
    	    run("Clear Results");
    	    
        	roiManager("Select", j);
    
    		profile = getProfile();
 			for (k = 0; k < profile.length; k++){
        		setResult("Value", k, profile[k]);
 			}
 		
	  		updateResults;
    		saveAs("Results", output + filename + "_" + colours[i] + "_ch" + "_line" + j + ".csv");
    	}
    }
    
    
    
    

	roiManager("Deselect");
    roiManager("Delete");
    
    close("*");

    
}







//===============================================================
//run analysis
//===============================================================


//set seed for pseudorandom number generator
random("seed", 73659);



//input and output directories

input    = "/Users/yangchen/microscopy/metallography/organpipe/micrographs/";
output   = "/Users/yangchen/microscopy/metallography/organpipe/data/";
overlays = "/Users/yangchen/microscopy/metallography/organpipe/overlays/";

filelist = getFileList(input);



radius = 50;    //pixel radius for median filter
nlines = 5;    //number of random lines to draw in each micrograph
scale = 0.5;	//pixels per micron



//disable all other measurements when measuring length of intersect
run("Set Measurements...", "  redirect=None decimal=2");



for (i = 0; i < filelist.length; i++){
	extractprofile(input, output, overlays, filelist[i], radius, scale);
	run("Collect Garbage");
}


selectWindow("Results"); run("Close");
close("ROI Manager");


