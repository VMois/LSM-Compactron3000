#include "xaxidma.h"
#include "xparameters.h"
#include "xil_cache.h"
#include "stdio.h"

u32 checkHalted(u32 baseAddress,u32 offset);

int main() {
    const int len = 14;

    // Two KV pairs
    u32 a[] = {0x00040200, 1, 2, 3, 4, 5, 6, 0x00040200, 7, 8, 9, 10, 11, 12};
    u32 b[len];
    u32 status;

    XAxiDma_Config *myDmaConfig;
    XAxiDma myDma;

    myDmaConfig = XAxiDma_LookupConfigBaseAddr(XPAR_AXI_DMA_0_BASEADDR);
    status = XAxiDma_CfgInitialize(&myDma, myDmaConfig);
    if(status != XST_SUCCESS){
        print("DMA initialization failed\n");
        return -1;
    }
    print("DMA initialization success..\n");

    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
    xil_printf("Status before data transfer %0x\n",status);
    Xil_DCacheFlushRange((u32) a, len*sizeof(u32));

    status = XAxiDma_SimpleTransfer(&myDma, (u32) b, len*sizeof(u32), XAXIDMA_DEVICE_TO_DMA);
    status = XAxiDma_SimpleTransfer(&myDma, (u32) a, len*sizeof(u32), XAXIDMA_DMA_TO_DEVICE);
    if(status != XST_SUCCESS){
        print("DMA initialization failed\n");
        return -1;
    }

    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
    while(status != 1){
        status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x4);
    }

    status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
    while(status != 1){
        status = checkHalted(XPAR_AXI_DMA_0_BASEADDR,0x34);
    }
    print("DMA transfer success..\n");
    for (int i=0; i < len; i++) {
        xil_printf("%0x\n",b[i]);
    }
}


u32 checkHalted(u32 baseAddress,u32 offset){
    u32 status;
    status = (XAxiDma_ReadReg(baseAddress,offset))&XAXIDMA_HALTED_MASK;
    return status;
}
