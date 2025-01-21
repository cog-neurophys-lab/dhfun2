# Changelog for dhfun2

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
