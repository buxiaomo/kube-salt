#!/usr/bin/env python

import socket


def fqdn_ip():
    return {
        'saltstack_default_ipv4': socket.gethostbyname(socket.getfqdn())
    }
