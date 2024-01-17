import sys
import gzip
import random

def main():
    if len(sys.argv) != 3:
        print("Usage: python script.py input.vcf.gz sample_name")
        sys.exit(1)

    vcf_filename = sys.argv[1]
    sample = sys.argv[2]

    with gzip.open(vcf_filename, 'rt') as vcf_read:
        process_vcf(vcf_read,sample)


def process_vcf(vcf_read, sample):
    current_chrom = None
    fasta_write = None
    base_count = 0

    for line in vcf_read:
        if line.startswith('#'):
            continue

        columns = line.strip().split()
        chrom = columns[0]

        if chrom != current_chrom:
            # Close the previous file and open a new one for the current chromosome
            if fasta_write:
                print("", file=fasta_write)  # Add a newline after the last base
                fasta_write.close()

            current_chrom = chrom
            output_filename = f"{sample}_{chrom}.fasta"
            fasta_write = open(output_filename, 'w')
            print(">" + sample, file=fasta_write)
            base_count = 0  # Reset base count for the new chromosome

        pos = columns[1]
        ref = columns[3]
        alt = columns[4]
        info = columns[7].strip().split(";")
        geno = columns[9].split(":")[0]

        base = determine_base(geno, ref, alt)
        print(base, end="", file=fasta_write)
        base_count += 1

        if base_count == 60:
            print("", file=fasta_write)  # Introduce a newline after every 60 bases
            base_count = 0  # Reset the base count

    # Close the last file
    if fasta_write:
        print("", file=fasta_write)  # Add a newline after the last base
        fasta_write.close()

def determine_base(geno, ref, alt):
    if geno == "0/1":
        return random.choice([ref, alt])
    elif geno == "0/0":
        return ref
    elif geno == "1/1":
        return alt
    else:
        return "N"

if __name__ == "__main__":
    main()
