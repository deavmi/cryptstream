module cryptstream.streams.client;

import botan.tls.client;

import river.core : RiverStream = Stream, StreamException, StreamError;

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
    }

    private void tlsOutputHandler(in ubyte[] dataOut)
    {

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