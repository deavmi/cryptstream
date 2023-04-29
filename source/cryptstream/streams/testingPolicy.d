module cryptstream.streams.testingPolicy;

import botan.tls.policy : TLSPolicy;
import botan.tls.client : TLSProtocolVersion;

public class TestingPolicy : TLSPolicy
{
    public override const bool acceptableProtocolVersion(TLSProtocolVersion _version) 
    {
        return true;
    }

    public override const bool sendFallbackSCSV(in TLSProtocolVersion _version)
    {
        return false;
    }
}