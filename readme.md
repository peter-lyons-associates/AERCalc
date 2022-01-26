# WincovER Desktop Client

## Copyright

(WincovER copyright notice and license information coming soon.)

AERCalc is Copyright (c) 2019, The Regents of the University of California, through Lawrence Berkeley National Laboratory (subject to receipt of any required approvals from the U.S. Dept. of Energy).  All rights reserved.


## Build Instructions

This repository is the Apache Flex / AIR project for the WincovER desktop client. Is it based on the open source LBNL AERCalc project.

To build it, you'll need :
1. Install ant
I think you only need to get to step 4 in "The Short Story" here: https://ant.apache.org/manual/install.html

2. Download, unzip and store the Flex/AIR combined SDK (from the convenience download in our shared dropbox). I have my own stored like so: 
    D:\FLEXSDKS\4.16.1_Air32

3. In your local repo clone, 

 a) look inside the build folder, and file copy local.properties.template to local.properties 

 b) edit the new local.properties file in a text editor and change the following line:

    `#FLEX_HOME = $\{basedir\}/../FLEXSDKS/4.16.1_Air32`

   i) remove the # at the beginning (this uncomments that line)

   ii) change the content after the "=" to the absolute path to the Flex/AIR SDK in step 2. If you are using backslashes, string rules apply, so they need to be escaped (basically '\\' instead of '\').
   You could simply use forward slashes instead.
    Example (from my system):

    FLEX_HOME = D:\\FLEXSDKS\\4.16.1_Air32

or 

    FLEX_HOME = D:/FLEXSDKS/4.16.1_Air32

4. open a command prompt inside the build directory. Then type 'ant' and press enter. The build should complete (clean and compile the Flex application and then package the AIR application)
The build output is placed inside a project level 'bin' folder, and contains a package.zip convenience zip.

