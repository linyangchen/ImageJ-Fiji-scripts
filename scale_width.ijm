
//==============================================
//==============================================

//batch automeasure greatest horizontal widths of fish scales


//Lin Yangchen
//Centre for Bioimaging Sciences
//National University of Singapore
//December 2024

//==============================================
//==============================================


//NOTES FOR USER

//image file(s) should have TIF or tif extension

//only one scale should be visible in the image

//scale should already be oriented vertically

//scale should be stained magenta against bright neutral-grey background

//unstained regions inside scale boundary will not affect measurements

//More than one row of pixels may give the same maximal width measurement.
//The program uses the last such row.



//fine-tune these parameters if necessary

//for a given pixel, green value should be smaller than this percentage
//of red value for the pixel to be considered as part of the scale
green = 0.8;

//for a given pixel, red value should be larger than this
//to exclude dirt spots in the image
red = 100;


//==============================================

//prompt user to select folder containing images
dir = getDirectory("choose folder");

//replace backslashes with forward slashes (if using Windows)
dir = replace(dir, "\\", "/");

//remove spaces and illegal characters in file names
run("Fix Funny Filenames", "which="+dir);

//get the list of files in the folder
filelist = getFileList(dir);

//create subfolder for results
output = dir + "results/";

File.makeDirectory(output);

//==============================================



setBatchMode(true); //do not display images during execution


//table for storing scale widths
Table.create("scalewidths");

//array to temporarily store R, G values of each pixel
chvals = newArray(2);

count = 0;


for (i = 0; i < filelist.length; i++)
{

	if (endsWith(filelist[i], ".TIF") || endsWith(filelist[i], ".tif"))
	{

	count = count + 1;
	print("processing " + filelist[i] + " (image " + count + ")");
	
	open(dir + filelist[i]);
	filename = File.nameWithoutExtension;

	//extract pixel dimensions
	h = getHeight;
	w = getWidth;
	
	//duplicate image for processing
	run("Duplicate...", " ");

	//separate into R, G, B channels
	run("RGB Stack");


	//for each row
	//arrays to store data (0-indexing)
	row_widths = newArray(); //width of scale in each row
	row_nums = newArray(); //corresponding row number
	firstpix = newArray(); //position of first scale pixel
	lastpix = newArray(); //position of last scale pixel
	
	for (r = 0; r < h; r++)
	{
		
		//array for pixel positions satisfying threshold
		//percentage green channel to be identified as scale
		pixpos = newArray(); //0-indexing
		
		//for each pixel in the row
		for (p = 0; p < w; p++)
		{

			//find pixel values of R and G channels
			for (c = 1; c <= 2; c++)
			{
				Stack.setChannel(c); //select channel (1-indexing)
				val = getPixel(p,r);
				chvals[c-1] = val; //0-indexing
				if(c == 1)
				{
					redval = val; //for checking red pixel value to exclude dirt
				} 
			} //end of channel loop
	
			//calculate whether pixel is part of scale
			percent_green = chvals[1]/chvals[0];
			
			//if criteria satisfied, append pixel position
			if(percent_green < green && redval > red)
			{
				pixpos = Array.concat(pixpos, p);
			}
	
		} //end of pixel loop
		
		//if length of pixpos is not 0 (row contains scale pixels)
		if(pixpos.length > 0)
		{
		
			//for this row, find min/max pixel positions and
			Array.getStatistics(pixpos, pixmin, pixmax, mean, std);

			firstpix = Array.concat(firstpix, pixmin); //record position of first scale pixel
			lastpix = Array.concat(lastpix, pixmax); //record position of last scale pixel
			
			//subtract the two values to get scale width
			row_widths = Array.concat(row_widths, pixmax - pixmin);
		
			//record corresponding row number
			row_nums = Array.concat(row_nums, r);
			
		} //end of if statement excluding empty rows
	
	} //end of row loop

	//sort all arrays according to row_widths
	Array.sort(row_widths, row_nums, firstpix, lastpix);
	
	//max scale width
	maxwidth = row_widths[row_widths.length - 1]; //last element of sorted array
	
	//optional code to convert width in pixel units to actual width
	//(not implemented)
	
	//corresponding row number
	maxrow = row_nums[row_nums.length - 1];
	
	//append scale width to table
	selectWindow("scalewidths");
	Table.set("image", i, filelist[i]);
	Table.set("scalewidth", i, maxwidth);


	//overlay measurement line on image
	selectImage(filelist[i]);
	makeLine(firstpix[firstpix.length - 1], maxrow, lastpix[lastpix.length - 1], maxrow);
	run("Flatten");
	saveAs("Jpeg", output + filename + "_width_line.jpg");


	run("Collect Garbage"); //clear memory
	
	
	} //end of if statement for file format

} //end of filelist loop




//==============================================


//save csv of scale widths
selectWindow("scalewidths");
saveAs("Results", output + "scalewidths.csv");

//if you want to close table window automatically
//selectWindow("scalewidths.csv"); run("Close");



print("yahoo!!! job finished");





