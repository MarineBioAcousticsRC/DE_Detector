# Density Estimation Detector

Set of scripts to detect odontocete clicks above a threshold recieved level in xwav data. This two-pass detector is based on and incorporates previous work by Marie A. Roch, Simone Baumann-Pickering, and Sean M. Wiggins. 
Detector by Kait E. Frasier.



## How To Use This Code:

1. Place /DE_Detector/ and all subdirectories in Matlab path

2. Edit low resolution detector parameters 
		dLoad_STSettings.m

3. Edit high resolution detector parameters 
		dLoad_HRSettings.m

4. Edit the following lines at the top of *de_detector.m* to reflect your file locations, and which routines to run*

```matlab
% Set transfer function location
tfFullFile = 'E:\Code\TF_files\585_091116_invSensit_MC.tf';
 
% Location of files to be analyzed
baseDir = 'H:\';
 
% Name of the deployment. This should be the first few characters in the
% names of the xwav files you want to look at.
depl = 'GofMX';
 
% Set flags indicating which routines to run. 
lowResDet = 1; %run short time detector.
highResDet = 1; %run high res detector

```

* NOTE: The high res detector relies on output from the low res step, but once you've run the low res, you don't need to re-run it, unless you change your parameters.


## Things to know

 - This detector is set up to run without manual detection inputs. Adding the option to choose times based on a manual pass is trivial, but not currently implemented.

- .wav file inputs are not currently supported.

- Currently optimized for dolphins in the Gulf of Mexico. Use cautiously, especially if adapting to other odontocetes. 

- In noisy areas, a more restrictive postprocessing step is possible. Email for more info.

- Let me know if/when you run into issues...