# SMAESD

This work is part of our paper **"Subdomain Protection is Needed: An SPF and DMARC-based Empirical Measurement Study and Proactive Solution of Email Security"**. This paper has been accepted by **the 42nd International Symposium on Reliable Distributed Systems (SRDS 2023)**.

The source code is in /SMAEDS.

## Main Purpose
This method is mainly used to help domain administrators detect attacks that attempt to use the domain name to send spoofed emails to the public in a timely manner.

## How To Deploy
You should use Bind9 to build a local DNS server, configure it and bind that server to a public available domain, for example dnstest.com. After that all SPF verification information of illegal emails will be sent to that DNS server.

The ssmtp service also needs to be configured on this server. When alarm messages appear, the system will automatically invoke the ssmtp service to send event detection reports to the specified administrator mailbox.

Add statements to the original SPF record using SPF's macro mechanism, and add SPF record as follows.

include:%{i}_id_%{l}_dm_%{o}_host_%{h}_domain_%{d}_.XXX.com
