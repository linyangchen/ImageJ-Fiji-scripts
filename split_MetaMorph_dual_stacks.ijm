
//===============================================
// Lin Yangchen
// NUS Centre for Bioimaging Sciences
// 29 June 2023
//===============================================




//===============================================
// User settings
//===============================================

//put all the data files in a folder and specify its path here
input = "/Users/yangchen/Desktop/livesr/orig/";

//create a folder for the split files
output = "/Users/yangchen/Desktop/livesr/split/";


//===============================================


setBatchMode(true); //do not display images during execution

outputL = output + "L/"; File.makeDirectory(outputL);
outputR = output + "R/"; File.makeDirectory(outputR);

filelist = getFileList(input);

count = 0;

for (i = 0; i < filelist.length; i++)
{
		if (endsWith(filelist[i], ".TIF"))
		{
		
			count = count + 1;
			print("processing image " + count);
		
			open(input + filelist[i]);
			name = File.nameWithoutExtension;
		
			rename("duplicate1");
        	run("Duplicate...", "title=duplicate2 duplicate");
            
        	makeRectangle(0, 0, 1200, 1200);
        	run("Crop");
			saveAs("Tiff", outputL + filelist[i]);

        	selectWindow("duplicate1");
        	makeRectangle(1200, 0, 1200, 1200);
        	run("Crop");
			saveAs("Tiff", outputR + filelist[i]);

			run("Close All");
			run("Collect Garbage");

		} else if(endsWith(filelist[i], ".nd"))
		{
			File.copy(input + filelist[i], outputL + filelist[i]);
			File.copy(input + filelist[i], outputR + filelist[i]);
		}
}


print("job done");
