# Changelog for dhfun2

## v2026.01.19 - 2026-01-19

- **Added**: Full write support for CONT blocks with `writecont` and `writecontindex` functions
- **Added**: Complete write support for SPIKE blocks with `createspike`, `writespike`, `writespikecluster`, and `writespikeindex` functions
- **Added**: Writing WAVELET data including `createwavelet`, `writewavelet`, and `writewaveletindex` functions
- **Added**: Writing events with `createev2` and `writeev2` functions for EV02 datasets
- **Added**: Writing of trial maps with `settrialmap` function for TRIALMAP datasets
- **Added**: Operation logging functionality in `dh.close` for tracking file modifications
- **Added**: `createfile` function to generate minimal valid DAQ-HDF5 files with required attributes
- **Added**: `createoperation` function for creating operation log entries
- **Added**: `forceDelete` option to `dh.open` for automatic file deletion without confirmation when opened with `'w'`
- **Added**: DAQ-HDF5 specification document (`doc/spec.md`) including a new section on WAVELET data
- **Fixed**: Allow CONT id equal to 0
- **Fixed**: Added try/catch for closing HDF5 groups to prevent errors
- **Fixed**: Test dependencies issues 

## v2025.01.21 - 2025-01-21

- **Fixed**: The indices returned by `readcontindex` and `readwaveletindex` were given out
  zero-based (as stored in the HDF5 file) and not one-based (as in dhfun version 1 and 
  promised in the documentation).

## v2023.10.19 - 2023-10-19

- **Added**: `dh.ft_read_cont` for reading continuous data from `CONT` blocks as Fieldtrip
  `ft_datatype_raw` including event triggers and trial information.

## v2023.07.11 - 2023-07-11

- Initial release of `dhfun2` providing functions for reading DH5 files and an API that can
  act as a drop-in replacement for the legacy `dhfun`.
