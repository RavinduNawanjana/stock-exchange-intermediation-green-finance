# Data provenance

## Source

This repository is built only from the Figshare supplementary package supplied by the author. The source package contains:

- `Dataset_S1_Raw_Survey_Data.xlsx`
- `Dataset_S2_SPSS_Data_File.sav`
- `Dataset_S3_SPSS_Output.spv`
- `README.txt`

The Figshare README documents 103 respondents, 30 five-point Likert items, the item-to-construct mapping, five SPSS composite variables, and the role of the original SPSS output file.

## Immutable originals

Files in `data/original/` are copied byte-for-byte from the supplied Figshare ZIP and are never modified by the analytical workflow. Their SHA-256 values are recorded in `SOURCE_MANIFEST.sha256`.

## Derived snapshots

`data/derived/survey_raw.csv` and `data/derived/codebook.csv` are plain-text snapshots extracted from the Excel workbook for inspectability. The R validation step asserts exact equality between the raw CSV matrix and the XLSX `Raw_Data` sheet.

## Source-of-truth order

1. Original XLSX for item-level analysis and codebook.
2. Original SAV for reconciliation of items, composites and source SPSS structure.
3. Original SPV retained as immutable evidence only.
4. Derived CSV files for human-readable inspection and cross-language QA.

The associated paper PDF is deliberately outside the repository and is not part of the computational source chain.
