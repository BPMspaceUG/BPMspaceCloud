#!/bin/bash
# Bestehende Tables löschen
/sbin/iptables -F

# Alle eingehenden Verbindungen verbieten
/sbin/iptables -P INPUT DROP
/sbin/iptables -P FORWARD DROP

# Alle ausgehenden erlauben
/sbin/iptables -P OUTPUT ACCEPT

# Traffic auf port 7070 (sshd) und 4040 (http) und 5050 (https) erlauben
/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 4040
/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 5050
/sbin/iptables -A INPUT -j ACCEPT -p tcp --dport 7070



# Alles von Localhost erlauben. (Damit der Server selbst ungehindert auf seine Dienste zugreifen kann,
# zum Beispiel PHP auf die lokale Datenbank
/sbin/iptables -A INPUT -j ACCEPT -s 127.0.0.1

# Bereits aufgebaute Verbindungen werden an jedem Port akzeptiert
# (Damit Antworten auf Anfragen, die vom Server kommen immer zurückkommen können)
/sbin/iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
