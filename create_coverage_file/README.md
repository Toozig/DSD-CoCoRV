# CoCoRV Burden Test Protocol - Create Coverage File Pipeline

## Overview

The Create Coverage File Pipeline is a part of the [CoCoRV (Cohort-based Comprehensive Rare Variant) burden test protocol](https://pubmed.ncbi.nlm.nih.gov/35545612/). This Nextflow script processes the gnomAD v3 coverage file to create a reading depth coverage. The resulting output is useful for downstream analysis in the CoCoRV protocol.

## Parameters

- **`coverageFile`** - Path to the gnomAD coverage file (`gnomad.genomes.r3.0.1.coverage.summary.tsv.bgz`).
  
- **`mergeDistance`** - The distance between segments to be merged into one segment. Default value is 1.

- **`outputFile`** - Output file name for the processed coverage data.

- **`outputDir`** - Output directory where the results will be stored.

## Example Command

```bash
~/nextflow run create_coverage_file.nf --coverageFile gnomad.genomes.r3.0.1.coverage.summary.tsv.bgz -params-file create_coverage_file.json -c process-selector.confi
```

## Command Explanation

- `~/nextflow run create_coverage_file.nf` - Execute the Nextflow script named `create_coverage_file.nf`.

- `--coverageFile gnomad.genomes.r3.0.1.coverage.summary.tsv.bgz` - Specify the path to the gnomAD coverage file.

- `-params-file create_coverage_file.json` - Use the parameters specified in the JSON file named `create_coverage_file.json`.

- `-c process-selector.confi` - Use the configuration file `process-selector.confi` for process customization.

## Notes

- Ensure that Nextflow is properly installed and configured on your system.

- The `coverageFile` parameter should point to the gnomAD v3 coverage file in the specified format.

- Adjust the `mergeDistance` parameter as needed based on your analysis requirements.

- The output will be saved in the specified `outputDir` with the provided `outputFile` name.

- Review the Nextflow documentation for more information on running and customizing workflows: [Nextflow Documentation](https://www.nextflow.io/docs/latest/index.html)

## Dependencies

- [Nextflow](https://www.nextflow.io/) - v23.04.2
- [Bedtools](https://bedtools.readthedocs.io/en/latest/) - v2.27.1

## Contact

For questions or issues, please contact me.

---
