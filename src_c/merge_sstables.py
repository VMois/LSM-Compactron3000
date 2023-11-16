import argparse

def merge_sstables(sstable1, sstable2):
    result = []
    i, j = 0, 0

    while i < len(sstable1) and j < len(sstable2):
        key1, value1 = sstable1[i].strip().split(':')
        key2, value2 = sstable2[j].strip().split(':')

        if key1 < key2:
            result.append((key1, value1))
            i += 1
        elif key1 > key2:
            result.append((key2, value2))
            j += 1
        else:  # keys are equal
            # In a real LSM-tree merge, you might have additional logic here
            # to handle conflicts or choose the latest value.
            result.append((key1, value1))
            i += 1
            j += 1

    # Add remaining entries from both lists, if any
    while i < len(sstable1):
        key, value = sstable1[i].strip().split(':')
        result.append((key, value))
        i += 1

    while j < len(sstable2):
        key, value = sstable2[j].strip().split(':')
        result.append((key, value))
        j += 1

    return result

def write_to_file(pairs, filename):
    with open(filename, 'w') as output:
        for key, value in pairs:
            output.write(f"{key}:{value}\n")

def main():
    parser = argparse.ArgumentParser(description="Merge SSTable files.")
    parser.add_argument("file1", help="Path to the first input file")
    parser.add_argument("file2", help="Path to the second input file")
    parser.add_argument("output_file", help="Path to the output merged file")
    args = parser.parse_args()

    with open(args.file1, 'r') as f1, open(args.file2, 'r') as f2:
        lines1 = f1.readlines()
        lines2 = f2.readlines()

    merged_pairs = merge_sstables(lines1, lines2)
    write_to_file(merged_pairs, args.output_file)

    print(f"Merged result written to {args.output_file}.")

if __name__ == "__main__":
    main()
