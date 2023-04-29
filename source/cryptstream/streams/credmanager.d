module cryptstream.streams.credmanager;

import botan.tls.client;
import  botan.math.bigint.bigint : BigInt;

public class CredManager : TLSCredentialsManager
{
    public override Vector!CertificateStore trustedCertificateAuthorities(in string type, in string context)
    {
        return super.trustedCertificateAuthorities(type, context);
    }

    public override void verifyCertificateChain(in string type, in string purported_hostname, const ref Vector!X509Certificate cert_chain)
    {
        return super.verifyCertificateChain(type, purported_hostname, cert_chain);
    }

    public override Vector!X509Certificate certChain(const ref Vector!string cert_key_types, in string type, in string context)
    {
        return super.certChain(cert_key_types, type, context);
    }

    public override Vector!X509Certificate certChainSingleType(in string cert_key_type, in string type, in string context)
    {
        return super.certChainSingleType(cert_key_type, type, context);
    }

    public override PrivateKey privateKeyFor(in X509Certificate cert, in string type, in string context)
    {
        return super.privateKeyFor(cert, type, context);
    }

    public override bool attemptSrp(in string type, in string context)
    {
        return super.attemptSrp(type, context);
    }

    public override string srpIdentifier(in string type, in string context)
    {
        return super.srpIdentifier(type, context);
    }

    public override string srpPassword(in string type, in string context, in string identifier)
    {
        return super.srpPassword(type, context, identifier);
    }

    public override bool srpVerifier(in string type,
                              in string context,
                              in string identifier,
                              ref string group_name,
                              ref BigInt verifier,
                              ref Vector!ubyte salt,
                              bool generate_fake_on_unknown)
    {
        return super.srpVerifier(type, context, identifier, group_name, verifier, salt, generate_fake_on_unknown);
    }

    public override string pskIdentityHint(in string type, in string context)
    {
        return super.pskIdentityHint(type, context);
    }

    public override string pskIdentity(in string type, in string context, in string identity_hint)
    {
        return super.pskIdentity(type, context, identity_hint);
    }

    public override bool hasPsk()
    {
        return super.hasPsk();
    }

    public override PrivateKey channelPrivateKey(string hostname)
    {
        return super.channelPrivateKey(hostname);
    }

    public override  SymmetricKey psk(in string type, in string context, in string identity)
    {
        return super.psk(type, context, identity);
    }
}