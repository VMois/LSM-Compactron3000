LSM-Compactron3000
=======================

The FPGA accelerator for speeding up the compaction process in LSM databases.
Based on [Teng Zhang et. al. paper](https://www.usenix.org/system/files/fast20-zhang_teng.pdf).

The hardware design is described in [Chisel3](https://github.com/chipsalliance/chisel).

## Design

In this part, you will find a detailed description of the design of the *LSM-Compactron3000*.

### KV Ring Buffer

Is a circular buffer that caches decoded **Key/Value** (KV) pairs from the decoder. It has **32 x 8KB** size (key - 2KB, value - 6KB) defined in the paper. The decoder and KV ring buffer are connected by a 8-byte width bus. 

The ring buffer implements a modified ready/valid handshake protocol, with `lastInput` and `lastOuput` signals. The `lastInput` signal is asserted by the sender to indicate to the ring buffer that the current valid value is the last chunk. The similar approach is taken by the ring buffer to output a KV pair.

Remember that 'last' (or any similar end-of-transfer signal) needs to be synchronized with the data and the 'valid' signal. If 'last' is asserted, it refers to the data that is currently on the bus and being marked as 'valid'. Also, like 'valid' and 'ready', 'last' would need to remain high until the data is accepted. This is because the receiver might not be ready to accept the data in the same cycle that 'valid' and 'last' are asserted, so these signals need to remain asserted until the receiver indicates that it's ready.

The read pointer is moved forward by asserting `moveReadPtr` input signal. The write pointer is moved forward when a new KV pair is written to the buffer unless buffer is full.

The KV ring buffer outputs key value only if `outputKeyOnly` input signal is asserted. If not, it will transfer both key and value on a bus.

The ring buffer also has three output signals `empty`, `full`. They are used by a control unit to control the decoder.

## Development

### Create Docker Image

```bash
docker build -t scala:v1 .
docker run -v <absolute-path>/LSM-Compactron3000:/design -it scala:v1 bash
```

### Run

You can run the included test with:
```sh
sbt test
```

To run the main program, you can use:
```sh
sbt run
```
