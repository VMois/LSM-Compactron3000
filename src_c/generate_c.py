import argparse
import struct
import math


def generate_c_array(filename, array_name, sstable):
    with open(filename, 'a') as c_file:
        num_u32_values = 0
        c_file.write(f"u32 {array_name}[] = {{\n")

        for i, (key, value) in enumerate(sstable):
            chars_per_value = 4
            key_iterations = math.ceil(len(key) / chars_per_value)
            value_iterations = math.ceil(len(value) / chars_per_value)
            num_u32_values += 1 + key_iterations + value_iterations

            metadata = (value_iterations << 16) | (key_iterations << 8)
            metadata |= 1 if i == len(sstable) - 1 else 0
            c_file.write(f"    0x{metadata:08X},\n")

            for j in range(key_iterations):
                key_suffix_index = min(j*chars_per_value + chars_per_value, len(key))
                combined_key = struct.unpack('>I', key.encode('ascii')[j*chars_per_value:key_suffix_index].ljust(4, b'\0'))[0]
                c_file.write(f"    0x{combined_key:08X},\n")
            
            for j in range(value_iterations):
                value_suffix_index = min(j*chars_per_value + chars_per_value, len(value))
                combined_value = struct.unpack('>I', value.encode('ascii')[j*chars_per_value:value_suffix_index].ljust(4, b'\0'))[0]
                c_file.write(f"    0x{combined_value:08X},\n")
            
            c_file.write("\n")

        c_file.write("};\n")
        c_file.write(f"const int {array_name}_len = {num_u32_values};\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate C file from SSTable files.")
    parser.add_argument("sstable1", help="Path to the first SSTable file")
    parser.add_argument("sstable2", help="Path to the second SSTable file")
    parser.add_argument("merged", help="Path to the merged SSTable file")
    parser.add_argument("-o", "--output", type=str, default="output.c", help="Output C file")
    args = parser.parse_args()

    with open(args.output, 'w') as c_file:  # Create or overwrite the C file
        c_file.write("// Auto-generated by generate_c.py\n\n")

    with open(args.sstable1, 'r') as f1, open(args.sstable2, 'r') as f2, open(args.merged, 'r') as f_merged:
        sstable1 = [line.strip().split(":") for line in f1.readlines()]
        sstable2 = [line.strip().split(":") for line in f2.readlines()]
        merged_sstable = [line.strip().split(":") for line in f_merged.readlines()]

    generate_c_array(args.output, "file1", sstable1)
    generate_c_array(args.output, "file2", sstable2)
    generate_c_array(args.output, "merged", merged_sstable)

    print(f"C file generated and saved to {args.output}.")
