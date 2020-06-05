# dnscrypt-proxy

I use [DNSCrypt](https://github.com/DNSCrypt/dnscrypt-proxy) on my local machines to secure my DNS queries. On NixOS, the service and config are automatically managed by the OS, but the Ubuntu packaging of DNSCrypt (that I use on Mint) is horribly broken and so I have to resort to creating my own systemd unit and config. This directory contains exactly that.
