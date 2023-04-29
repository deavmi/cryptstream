module cryptstream.streams.client;

import river.core : RiverStream = Stream, StreamException, StreamError;
import core.thread : Thread;
import botan.tls.client;


// TODO: This should be a kind-of `RiverStream`, but
// ... we defs can take IN a stream to use as the underlying
// ... connection upon which the TLS data will be sent over
public class CryptClient : RiverStream
{
    /**
     * Underlying stream to use for TLS-encrypted communication
     */
    private RiverStream stream;

    /** 
     * Reads bytes from the underlying thread to pass
     * up to `receivedData()`
     */
    private Thread streamReader;
    
    /** 
     * Botan TLS client
     */
    private TLSClient botanClient;

    /** 
     * Constructs a new TLS-enabled client stream
     * Params:
     *   stream = 
     */
    this(RiverStream stream)
    {
        this.stream = stream;

        this.botanClient = new TLSClient(&tlsOutputHandler);

        // TODO: Insert code to init using botan OVER `stream`

        // TODO: Start a thread which can read from the socket
        // ... and then injct data to the Botan client to be decrypted
        // ... using `receivedData()`
        this.streamReader = new Thread(&streamReaderWorker);
        this.streamReader.start();

        // TODO: Add method which is passed to the BotanClient constructor
        // ... above which is called upon decrypting a tls record
        // ... then place this into a buffer here which our
        // ... `read/readFully` can read from
    }

    private void streamReaderWorker()
    {
        // TODO: Make this size configurable
        byte[100] readInto;
        while(true)
        {
            ulong receivedAmount = stream.read(readInto);

            // TODO: Use the hint byte count returned?
            botanClient.receivedData(cast(ubyte*)readInto.ptr, receivedAmount);
        }
    }

    // NOTE This gets called when the Botan client needs to write to
    // ... the underlying output. So If we were to call `botanClient.send`
    // ... (which takes in our plaintext), it would encrypt, and then
    // ... push the encrypted payload into this method here below
    // ... (implying we should write to our underlying stream here)
    private void tlsOutputHandler(in ubyte[] dataOut)
    {
        stream.writeFully(cast(byte[])dataOut);
    }

    
    public override ulong read(byte[] toArray)
    {
        /* Ensure the TLS session is active */
        openCheck();

        // TODO: Implement me
        return 0;
    }

    public override ulong readFully(byte[] toArray)
    {
        /* Ensure the TLS session is active */
        openCheck();

        // TODO: Implement me
        return 0;
    }

    public override ulong write(byte[] fromArray)
    {
        /* Ensure the TLS session is active */
        openCheck();

        // TODO: Implement me

        /* Send data to Botan */
        botanClient.send(cast(ubyte*)fromArray.ptr, fromArray.length);

        return 0;
    }

    
    public override ulong writeFully(byte[] fromArray)
    {
        /* Ensure the TLS session is active */
        openCheck();

        // TODO: Implement me

        // FIXME: Change this (if required), for now I am just going to call write
        return write(fromArray);

        // return 0;
    }

    public override void close()
    {
        // TODO: Implement me
    }

    /** 
     * Ensures that the TLS client is active is open, if not, then throws an
     * exception
     */
    private void openCheck()
    {
        if(!botanClient.isActive())
        {
            throw new StreamException(StreamError.CLOSED);
        }
    }
}