


//=================================================================================

//Generates a maximum-intensity Z-projected image with TrackMate overlay embedded
//Image can be zoomed in to more than 100% to display small ROIs clearly
//Saves tif and video

//Lin Yangchen
//NUS Centre for Bioimaging Sciences
//28 May 2023 

//=================================================================================




//============================================================

//User settings

//Before running the macro, select the image window with the
//overlay preview generated by TrackMate.
//Do not "Execute" the "Capture overlay" action in TrackMate.
//Move the mouse cursor out of the way and do not click or move anything on screen
//while the script is running.

//where to save files
output = "/Users/yangchen/Desktop/tracking/PengLing/LiveSR/chnredspot/"

//zoom in (percentage) if your ROI is very small
zoomlevel = 300

//============================================================




run("Z Project...", "projection=[Max Intensity] all");
run("Grays");
run("Enhance Contrast", "saturated=0.35");
rename("videoframes");
run("Set... ", "zoom="+zoomlevel);

//number of time points (frames)
Stack.getDimensions(width, height, channels, slices, frames); 


for (i = 1; i <= frames; i++)
{
	selectWindow("videoframes");
    Stack.setFrame(i);
    run("Capture Image");
    
    if(i == 1)
    {
    	rename("1");
    } else
    {
    	h = i - 1;
		run("Concatenate...", "title="+i+" open image1="+h+" image2=videoframes-1");
    }
}


saveAs("Tiff", output + "videoseq.tif");
run("AVI... ", "compression=None frame=3 save="+output+"video.avi");

selectWindow("videoframes");
close();
