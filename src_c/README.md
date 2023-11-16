# Software to control FPGA accelerator

Primarly used for a testing, not for production.

## Usage

### Generate SSTables

```bash
python generate_sstable.py --N1 50 --N2 30 --min-key-len 3 --max-key-len 10 -v 10 -s 0.6 -o1 buffer1_sstable.txt -o2 buffer2_sstable.txt
```

### Merge SSTables to get reference results

```bash
python merge_sstables.py buffer1_sstable.txt buffer2_sstable.txt merged.txt
```

### Generate C file with data aligned to 4-byte chunks

```bash
python generate_c.py buffer1_sstable.txt buffer2_sstable.txt merged.txt -o data.c
```
