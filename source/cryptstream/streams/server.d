module cryptstream.streams.server;

import botan.tls.server;
import river.core;
import river.impls.sock : SockStream;
import core.thread;
import botan.tls.credentials_manager;

public class CryptServerHandle
{
    private Stream clientSocket;

    private TLSServer server;
    
    // TODO: Setup
    private TLSSessionManager sessionManager = new  TLSSessionManagerNoop();
    private TLSCredentialsManager credentialManager;
    private TLSPolicy policy = new TLSPolicy();
    private RandomNumberGenerator rng;

    /** 
     * Reads, in its own thread, bytes from the client
     * and pushes them into the Botan server
     */
    private Thread streamReader;


    this(Stream clientSocket)
    {
        import std.stdio;
        writeln("HOL");

        this.rng = RandomNumberGenerator.makeRng();
        import cryptstream.streams.credmanager : CredManager;
        this.credentialManager = new CredManager();
        this.clientSocket = clientSocket;

        version(unittest)
        {
            import std.stdio;
            writeln("CryptServer ctor(): Before TLSServer creation");
        }

        this.server = new TLSServer(&tlsOutputHandler, &decryptedInputHandler, &tlsAlertHandler, &tlsHandshakeHandler,
                                        sessionManager, credentialManager, policy, rng);
        
        version(unittest)
        {
            import std.stdio;
            writeln("CryptServer ctor(): AFTER TLSServer creation");
        }

        this.streamReader = new Thread(&streamReaderWorker);
        this.streamReader.start();
    }

    private void streamReaderWorker()
    {
        // TODO: Make this size configurable
        byte[500] readInto;
        while(true)
        {
            ulong receivedAmount = clientSocket.read(readInto);

            version(unittest)
            {
                import std.stdio;
                import std.conv : to;
                writeln("streamReaderWorker(server-side): Transferring "~to!(string)(receivedAmount)~" many bytes over to Botan server...");
                writeln("streamReaderWorker(server-side): The bytes are: "~to!(string)(readInto[0..receivedAmount]));
            }

            // TODO: Use the hint byte count returned?
            server.receivedData(cast(ubyte*)readInto.ptr, receivedAmount);
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
        // ... into a buffer in CryptServer that can be read from
        // ... via `read/readFully`
    }

    private void tlsAlertHandler(in TLSAlert alert, in ubyte[] data)
    {

    }

    // NOTE This gets called when the Botan server needs to write to
    // ... the underlying output. So If we were to call `server.send`
    // ... (which takes in our plaintext), it would encrypt, and then
    // ... push the encrypted payload into this method here below
    // ... (implying we should write to our underlying stream here)
    private void tlsOutputHandler(in ubyte[] dataOut)
    {
        clientSocket.writeFully(cast(byte[])dataOut);
    }
}


version(unittest)
{
    import std.socket;
    import cryptstream.streams.client : CryptClient;
    import core.thread;

    public class Server : Thread
    {
        private Socket serverSocket;
        this(Address bindAddr)
        {
            serverSocket = new Socket(bindAddr.addressFamily(), SocketType.STREAM, ProtocolType.TCP);
            serverSocket.bind(bindAddr);
            serverSocket.listen(0);
            super(&begin);
        }


        private void begin()
        {
            while(true)
            {
                Socket clientSocket = serverSocket.accept();
                Stream clientStream = new SockStream(clientSocket);
                CryptServerHandle cryptoClientStream = new CryptServerHandle(clientStream);
                Connection clientConnection = new Connection(cryptoClientStream);
                clientConnection.start();
            }
        }
    }

    public class Connection : Thread
    {
        private CryptServerHandle client;

        this(CryptServerHandle client)
        {
            this.client = client;
            super(&worker);
        }

        private void worker()
        {
            while(true)
            {
                // TODO: Do something here with the client
                import std.stdio;
                writeln("Hello I am connection");
                Thread.sleep(dur!("seconds")(10));
            }
        }
    }
}
