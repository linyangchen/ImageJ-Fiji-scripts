
//===============================================
// Lin Yangchen
// NUS Centre for Bioimaging Sciences
// 29 June 2023
//===============================================




//===============================================
// User settings
//===============================================


input = "/Users/yangchen/Desktop/livesr/orig/";
output = "/Users/yangchen/Desktop/livesr/split/";


//===============================================


setBatchMode(true); //do not display images during execution

filelist = getFileList(input);

for (i = 0; i < filelist.length; i++)
{
		if (endsWith(filelist[i], ".TIF"))
		{
		
		count = i + 1;
		print("processing image " + count + " of " + filelist.length);
		
		open(input + filelist[i]);
		
		rename("duplicate1");
        run("Duplicate...", "title=duplicate2 duplicate");
           
        makeRectangle(0, 0, 1200, 1200);
        run("Crop");
		saveAs("Tiff", output + filelist[i] + "_L.tif");

        selectWindow("duplicate1");
        makeRectangle(1201, 0, 1200, 1200);
        run("Crop");
		saveAs("Tiff", output + filelist[i] + "_R.tif");

		run("Close All");
		run("Collect Garbage");

		}
}


print("job done");
