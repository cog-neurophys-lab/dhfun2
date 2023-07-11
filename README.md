dhfun2 - Reading DAQ-HDF5 files with MATLAB's HDF5 library
==========================================================

dhfun2 provides tools to read (and soon also write) data stored on disk using the in-house
DAQ-HDF5 (DH5) file format of the Cognitive Neurophysiology Lab at University of Bremen.

`dhfun2` can act as a drop-in replacement for the legacy function `dhfun`, which was using a
32-bit C++ library via MATLAB's legacy [C Matrix
API](https://de.mathworks.com/help/matlab/cc-mx-matrix-library.html). `dhfun2` instead
relies on MATLAB's built-in HDF5 functionality, and is therefore compatible with all
platforms supported by MATLAB (currently Windows, Linux, macOS and MATLAB Online). Since
`dhfun2` uses only 64-bit libraries, it can handle arrays larger than 4 GB and make use of
the full available system RAM.