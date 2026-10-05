# SPSS preservation and reconciliation boundary

The original `.sav` and `.spv` files are retained unchanged. R and Python independently verify that the `.sav` raw items correspond to the XLSX source and that documented composite mean variables correspond to direct item averaging.

The proprietary `.spv` viewer file is not parsed by repository code. Its presence preserves the original SPSS output record without pretending that a viewer file is executable syntax.
