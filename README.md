# Muse GUI (MATLAB)

Display and record EEG signals from Muse using MATLAB.

![Screenshot](https://raw.githubusercontent.com/pikipity/Muse-GUI-Matlab/master/Screenshot/Screenshot.JPG)

## Requirements

+ Now, this GUI is only tested on MATLAB 2015b and Windows 10.
+ [BlueMuse](https://github.com/kowalej/BlueMuse)
+ [liblsl-Matlab](https://github.com/labstreaminglayer/liblsl-Matlab)
+ [Fast ICA](https://www.mathworks.com/matlabcentral/mlc-downloads/downloads/submissions/49614/versions/2/previews/Thermal%20Pattern%20Separation/FastICA_25/fastica.m/index.html)

## Getting Start

1. Open BlueMuse.
2. Connect to Muse device, and start streaming.
3. Start Muse GUI by running `Main.m`.
4. Press "Connect". Then, you should see signals in GUI.
5. Press "Record" to save original data (without filters).
