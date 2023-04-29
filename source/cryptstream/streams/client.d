module cryptstream.streams.client;

import river.core : RiverStream = Stream, StreamException, StreamError;
import core.thread : Thread, dur;
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

    // TODO: Setup
    private TLSSessionManager sessionManager = new  TLSSessionManagerNoop();
    private TLSCredentialsManager credentialManager;

    import cryptstream.streams.testingPolicy;
    private TLSPolicy policy = new TestingPolicy();
    private RandomNumberGenerator rng;

    /** 
     * Constructs a new TLS-enabled client stream
     * Params:
     *   stream = 
     */
    this(RiverStream stream)
    {
        this.stream = stream;

        this.rng = RandomNumberGenerator.makeRng();
        // this.sessionManager = new  TLSSessionManagerInMemory(rng);

        import cryptstream.streams.credmanager : CredManager;
        this.credentialManager = new CredManager();

        // FIXME: Currently we are crashing with a segmentation fault here
        this.botanClient = new TLSClient(&tlsOutputHandler, &decryptedInputHandler, &tlsAlertHandler, &tlsHandshakeHandler,
                                        sessionManager, credentialManager, policy, rng);

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
        byte[500] readInto;
        while(true)
        {
            ulong receivedAmount = stream.read(readInto);

            version(unittest)
            {
                import std.stdio;
                import std.conv : to;
                writeln("streamReaderWorker(client-side): Transferring "~to!(string)(receivedAmount)~" many bytes over to Botan client...");
                writeln("streamReaderWorker(client-side): The bytes are: "~to!(string)(readInto[0..receivedAmount]));
                // writeln("streamReaderWorker(): The bytes are (as string): "~cast(string[])readInto[0..receivedAmount]);
                
            }

            // TODO: Use the hint byte count returned?
            botanClient.receivedData(cast(ubyte*)readInto.ptr, receivedAmount);
        }
    }

    private bool tlsHandshakeHandler(in TLSSession session)
    {
        // TODO: Implement me
        return true;
    }

    private void decryptedInputHandler(in ubyte[] receivedDecryptedData)
    {
        // TODO: This is now decrypted and THIS data should be placed
        // ... into a buffer in CryptClient that can be read from
        // ... via `read/readFully`
    }

    private void tlsAlertHandler(in TLSAlert alert, in ubyte[] data)
    {

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

        // TODO: It seems we can basically have everything or nothing
        // ... so just call read as the method of TLS records does this
        // ... to us
        return read(toArray);
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

version(unittest)
{
    import river.core;
    import river.impls : SockStream;
    import std.socket;
    import std.stdio;

    import cryptstream.streams.server;
}

unittest
{
    /** 
     * Setup a server
     */
    Address addr = parseAddress("::1", 1214);
    writeln("Binding server to: ", addr);
    Server server = new Server(addr);
    server.start();


    Socket endpoint = new Socket(AddressFamily.INET6, SocketType.STREAM, ProtocolType.TCP);
    
    
    endpoint.connect(addr);

    Stream stream = new SockStream(endpoint);
    CryptClient client = new CryptClient(stream);

    Thread.sleep(dur!("seconds")(3));

    // FIXME: This crashes as handshake doens't go through meaning the `isActive()` is false
    client.writeFully(cast(byte[])"ABBA");
    

    while(true){}
}