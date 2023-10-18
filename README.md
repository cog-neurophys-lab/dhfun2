dhfun2 - Reading DAQ-HDF5 files with MATLAB's HDF5 library
==========================================================

dhfun2 provides tools to read (and soon also write) data stored on disk using the in-house
[DAQ-HDF5 (DH5) file format](https://github.com/cog-neurophys-lab/DAQ-HDF5) of the Cognitive
Neurophysiology Lab at University of Bremen.

`dhfun2` can act as a drop-in replacement for the legacy function `dhfun` written by Michael
Borisov, which was using a 32-bit C++ library via MATLAB's now legacy [C Matrix
API](https://de.mathworks.com/help/matlab/cc-mx-matrix-library.html). `dhfun2` instead
relies on MATLAB's built-in HDF5 functionality, and is therefore compatible with all
platforms supported by MATLAB (currently Windows, Linux, macOS and MATLAB Online). Since
`dhfun2` uses only 64-bit libraries, it can handle arrays larger than 4 GB and make use of
the full available system RAM.

`dhfun2` is freely available under the MIT license (see the file LICENSE for details) and
contains code and/or ideas from

- Michael Borisov
- Joscha Schmiedt (schmiedt@uni-bremen.de)

Getting started with `dhfun2`
-----------------------------

To start using `dhfun2` for reading electrophysiology data from DH5 files you have three
options:

1. Download a [release](https://github.com/cog-neurophys-lab/dhfun2/releases) as zip file,
   unpack and add the folder to your MATLAB path.
2. Download a [release](https://github.com/cog-neurophys-lab/dhfun2/releases) as MATLAB
   Toolbox (mltbx) and install via double-click.
3. Clone the Git repository and add the folder to MATLAB path.


Reading DH5 data into Fieldtrip
-------------------------------

To load continous (CONT) data from a DH5 file into MATLAB in a format compatible with the
toolbox [Fieldtrip](https://www.fieldtriptoolbox.org) use the function
[`dh.ft_read_cont`](+dh/ft_read_cont.m):
```matlab
>>  [data, events] = dh.ft_read_cont(filename, contIDs);
```

Use the `events` in combination with a custom `trialfun` to create trials using
[`ft_redefinetrial`](https://github.com/fieldtrip/fieldtrip/blob/release/ft_redefinetrial.m).
See [`dh.trialfun_general`](+dh/trialfun_general.m) for an example.

This data can then directly be processed by Fieldtrip functions such as
[`ft_preprocessing`](https://github.com/fieldtrip/fieldtrip/blob/release/ft_preprocessing.m),
[`ft_timelockanalysis`](https://github.com/fieldtrip/fieldtrip/blob/release/ft_timelockanalysis.m),
or [`ft_freqanalysis`](https://www.fieldtriptoolbox.org/walkthrough/#frequency-analysis). See the [Fieldtrip documentation](https://www.fieldtriptoolbox.org/documentation/) for more information.
