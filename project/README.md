# Signal Compression Engine

This project demonstrates basic signal compression and pattern matching using ARM64 assembly. It includes a simple command line interface written in C that interacts with ARM64 assembly routines for compression, searching, utilities, and memory management.

## Building

Ensure the `aarch64-linux-gnu-gcc` cross compiler is installed. Then run:

```bash
make
```

## Usage Example

```bash
./sigscan data/sample_data.csv -rle -search "100 75" -stats
```

## Compression Algorithms

* **Run-Length Encoding (RLE)** stores value/count pairs for consecutive identical values.
* **Delta Encoding** stores the first value and the difference between consecutive values.

## Educational Objectives

* Practice AAPCS64 calling conventions
* Work with ARM64 load/store instructions
* Understand basic data processing and branching in assembly
* Interface between C and assembly
