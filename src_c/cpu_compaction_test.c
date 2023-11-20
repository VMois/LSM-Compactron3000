#include "stdio.h"
#include "xtime_l.h"

#include "data.c"
#define u32 int


inline void copy_kv_pairs(u32 *dst, u32 *src, int src_start, int src_end, int dst_start) {
    for (int l = src_start; l < src_end; l++) {
        dst[dst_start++] = src[l];
    }
}


int main() {
    // To measure number of clock cycles
    XTime tStart, tEnd;

    const int merged_results_len = merged_len;

    // +1 due to last signal will generate a junk data
    u32 merged_result[merged_results_len + 1];

    // Start testing
    XTime_GetTime(&tStart);

    // Merge two SSTables (file1 and file2)
    int file1Ptr = 0, file2Ptr = 0;
    int mergedPtr = 0;
    int last1 = 0, last2 = 0;

    while (last1 == 0 || last2 == 0) {
        // Get metadata
        u32 meta1 = file1[file1Ptr];
        u32 meta2 = file2[file2Ptr];
        last1 = meta1 & 0x1;
        last2 = meta2 & 0x1;
        u32 key1len = meta1 >> 8 & 0xFF;
        u32 key2len = meta2 >> 8 & 0xFF;
        u32 val1len = meta1 >> 16 & 0xFF;
        u32 val2len = meta2 >> 16 & 0xFF;

        // Compare keys
        int common_key_length = key1len < key2len ? key1len : key2len;
        int winner = 0;

        for (int k = 0; k < common_key_length; k++) {
            if (file1[file1Ptr + 1 + k] < file2[file2Ptr + 1 + k]) {
                // Copy KV pair from file1
                copy_kv_pairs(merged_result, file1, file1Ptr, file1Ptr + key1len + val1len + 1, mergedPtr);
                file1Ptr += key1len + val1len + 1;
                mergedPtr += key1len + val1len + 1;
                winner = 1;
                break;
            } else if (file1[file1Ptr + 1 + k] > file2[file2Ptr + 1 + k]) {
                // Copy KV pair from file2
                copy_kv_pairs(merged_result, file2, file2Ptr, file2Ptr + key2len + val2len + 1, mergedPtr);
                file2Ptr += key2len + val2len + 1;
                mergedPtr += key2len + val2len + 1;
                winner = 1;
                break;
            }
        }

        if (winner == 1) {
            continue;
        }

        // If keys are equal up to a common length, compare key lengths
        if (key1len < key2len) {
            // Copy KV pair from file1
            copy_kv_pairs(merged_result, file1, file1Ptr, file1Ptr + key1len + val1len + 1, mergedPtr);
            file1Ptr += key1len + val1len + 1;
            mergedPtr += key1len + val1len + 1;
            continue;
        } else if (key1len > key2len) {
            // Copy KV pair from file2
            copy_kv_pairs(merged_result, file2, file2Ptr, file2Ptr + key2len + val2len + 1, mergedPtr);
            mergedPtr += key2len + val2len + 1;
            file2Ptr += key2len + val2len + 1;
            continue;
        }

        // If lengths are equal, select file1 cause it is considered more up to date
        copy_kv_pairs(merged_result, file1, file1Ptr, file1Ptr + key1len + val1len + 1, mergedPtr);
        file1Ptr += key1len + val1len + 1;
        mergedPtr += key1len + val1len + 1;
        file2Ptr += key2len + val2len + 1;
    }

    // Copy the rest of the file1 or file2
    if (last1) {
        copy_kv_pairs(merged_result, file2, file2Ptr, file2_len, mergedPtr);
    } else if (last2) {
        copy_kv_pairs(merged_result, file1, file1Ptr, file1_len, mergedPtr);
    }

    // End testing
    XTime_GetTime(&tEnd);

    xil_printf("Processing took %llu clock cycles.\n", 2 * (tEnd - tStart));

    print("Comparing values..\n");
    int errors_num = 0;
    for (int i = 0; i < merged_results_len; i++) {
        if (merged_result[i] != merged[i]) {
            xil_printf("Error at index %d, expected %0x, got %0x\n", i, merged[i], merged_result[i]);
            errors_num++;
        }
    }
    print("Comparing is done. Number of errors is %d\n", errors_num);
    xil_printf("Comparing is done. Number of errors is %d\n", errors_num);
}

