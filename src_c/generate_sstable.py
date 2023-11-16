import argparse
import random
import string


def generate_random_string(length):
    return ''.join(random.choice(string.ascii_letters) for _ in range(length))


def generate_sstable_pairs(num_pairs1, num_pairs2, min_key_length, max_key_length, value_length, shared_percentage=0.5):
    shared_count = int(min(num_pairs1, num_pairs2) * shared_percentage)
    unique_count1 = num_pairs1 - shared_count
    unique_count2 = num_pairs2 - shared_count

    shared_keys = [generate_random_string(random.randint(min_key_length, max_key_length)) for _ in range(shared_count)]
    unique_keys1 = [generate_random_string(random.randint(min_key_length, max_key_length)) for _ in range(unique_count1)]
    unique_keys2 = [generate_random_string(random.randint(min_key_length, max_key_length)) for _ in range(unique_count2)]

    shared_pairs = [(key, generate_random_string(value_length)) for key in shared_keys]
    unique_pairs1 = [(key, generate_random_string(value_length)) for key in unique_keys1 if key not in shared_keys]
    unique_pairs2 = [(key, generate_random_string(value_length)) for key in unique_keys2 if key not in shared_keys]

    return sorted(shared_pairs + unique_pairs1), sorted(shared_pairs + unique_pairs2)

def write_to_file(pairs, filename):
    with open(filename, 'w') as file:
        for key, value in pairs:
            file.write(f"{key}:{value}\n")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate SSTable files.")
    parser.add_argument("--N1", type=int, default=10, help="Number of key-value pairs for file 1")
    parser.add_argument("--N2", type=int, default=10, help="Number of key-value pairs for file 2")
    parser.add_argument("--min-key-len", type=int, default=3, help="Minimum length of keys")
    parser.add_argument("--max-key-len", type=int, default=8, help="Maximum length of keys")
    parser.add_argument("-v", "--value-len", type=int, default=10, help="Length of values for each file")
    parser.add_argument("-s", type=float, default=0.5, help="Percentage of shared keys between SSTables")
    parser.add_argument("-o1", "--output1", type=str, default="output1.txt", help="Output filename for SSTable 1")
    parser.add_argument("-o2", "--output2", type=str, default="output2.txt", help="Output filename for SSTable 2")
    args = parser.parse_args()

    random_pairs1, random_pairs2 = generate_sstable_pairs(args.N1, args.N2, args.min_key_len, args.max_key_len, args.value_len, args.s)

    write_to_file(random_pairs1, args.output1)
    write_to_file(random_pairs2, args.output2)

    print(f"Random key-value pairs for each file written to {args.output1} and {args.output2}.")
