# Data Pulling & Storage

All scripts that pull data are stored here. Please note that flatfiles are notev directly saved in this folder. Datasets are either pulled from KIPP's Big query database or are downloaded from google cloud storage via R scripts. Any flatfiles that are read into this folder need to be included in the `.gitignore` file in order to avoid uploading to github.

**NOTE**: If files are encoded in a supported file format, they'll automatically be loaded when you call `load.project()`.
