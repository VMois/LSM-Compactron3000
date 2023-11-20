#include "xaxidma.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "stdio.h"
#include "xtime_l.h"

#include "data.c"

u32 checkHalted(u32 baseAddress, u32 offset);

u32 init_dma(XAxiDma_Config *dmaConfig, XAxiDma *dma) {
    u32 status = XAxiDma_CfgInitialize(&dma, dmaConfig);
    if(status != XST_SUCCESS){
        print("DMA initialization failed\n");
        return -1;
    }
    print("DMA initialization success..\n");
    return 0;
}


int main() {
    // To measure number of clock cycles
    XTime tStart, tEnd;

    const int merged_results_len = merged_len + 1;

    // +1 due to last signal will generate a junk data
    u32 merged_result[merged_results_len + 1];
    u32 status;

    XAxiDma_Config *dma1Config;
    XAxiDma dma1;

    XAxiDma_Config *dma2Config;
    XAxiDma dma2;

    dma1Config = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
    dma2Config = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_1_BASEADDR);

    if (init_dma(dma1Config, &dma1) != 0 || init_dma(dma2Config, &dma2)) {
        return -1;
    }

    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
    xil_printf("Status for DMA1 before data transfer %0x\n",status);

    status = checkHalted(XPAR_AXI_DMA_1_BASEADDR, 0x4);
    xil_printf("Status for DMA2 before data transfer %0x\n",status);

    // Flush cache for both memory ranges
    Xil_DCacheFlushRange((u32) file1, file1_len*sizeof(u32));
	Xil_DCacheFlushRange((u32) file2, file2_len*sizeof(u32));

    // TODO: set register to start for the LSM-Compactron3000 hardware

    // Start testing
    XTime_GetTime(&tStart);

    // Start DMA transfer to send data to FPGA
    status = XAxiDma_SimpleTransfer(&dma1, (u32) file1, file1_len*sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
    if(status != XST_SUCCESS){
        print("DMA1 transfer failed\n");
        return -1;
    }

    status = XAxiDma_SimpleTransfer(&dma2, (u32) file2, file2_len*sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
    if(status != XST_SUCCESS){
        print("DMA2 transfer failed\n");
        return -1;
    }

    // Start DMA transfer to receive results back
    status = XAxiDma_SimpleTransfer(&dma1, (u32) merged_result, merged_results_len*sizeof(u32), XAXIDMA_DMA_TO_DEVICE);
    if(status != XST_SUCCESS){
        print("DMA1 transfer back failed\n");
        return -1;
    }

    // wait for DMA 1, memory to device to finish
    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
    while(status != 1) {
        status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x4);
    }

    // wait for DMA 2, memory to device to finish
    status = checkHalted(XPAR_AXI_DMA_1_BASEADDR, 0x4);
    while(status != 1) {
        status = checkHalted(XPAR_AXI_DMA_1_BASEADDR, 0x4);
    }

    // wait for DMA 1, device to memory to finish
    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x34);
    while(status != 1) {
        status = checkHalted(XPAR_AXI_DMA_0_BASEADDR, 0x34);
    }

    // End testing
    XTime_GetTime(&tEnd);

    print("DMA transfer success..\n");
    xil_printf("Processing took %llu clock cycles.\n", 2 * (tEnd - tStart));

    print("Comparing values..\n");
    int errors_num = 0;
    for (int i=0; i < merged_results_len; i++) {
        if (merged_result[i] != merged[i]) {
            xil_printf("Error at index %d, expected %0x, got %0x\n", i, merged[i], merged_result[i]);
            errors_num++;
        }
    }
    xil_printf("Comparing is done. Number of errors is %d\n", errors_num);
}


u32 checkHalted(u32 baseAddress, u32 offset) {
    u32 status = XAxiDma_ReadReg(baseAddress, offset) & XAXIDMA_HALTED_MASK;
    return status;
}
