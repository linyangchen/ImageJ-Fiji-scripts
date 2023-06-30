//======================================
//3D segmentation
//Lin Yangchen
//NUS Centre for Bioimaging Sciences
//June 2023
//======================================

//requires 3D ImageJ Suite and MorphoLibJ

//====================
//USER SETTINGS

//no. of cores in your computer
ncores = 6;

//threshold value
thresh = 60;

//size range (voxels) for 3D object counter
minsize = 30000;
maxsize = 40000;

//for additional parameters see code below

//====================



//smooth out noise
run("3D Fast Filters","filter=Median radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus="+ncores);

run("3D Fast Filters","filter=OpenGray radius_x_pix=2.0 radius_y_pix=2.0 radius_z_pix=2.0 Nb_cpus="+ncores);

run("3D Simple Segmentation", "seeds=None low_threshold="+thresh+" min_size=0 max_size=-1");
selectWindow("Bin");

//fill holes and watershed
run("3D Fill Holes");
run("Distance Transform Watershed 3D", "distances=[Chessboard (1,1,1)] output=[16 bits] normalize dynamic=2 connectivity=6");

//convert back to binary
setAutoThreshold("Default dark no-reset stack");
run("Convert to Mask", "method=Default background=Dark black");

run("3D Objects Counter", "threshold=128 slice=21 min.="+minsize+" max.="+maxsize+" exclude_objects_on_edges objects surfaces centroids centres_of_masses statistics summary");

