# Python test
import socket
sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
sock.bind(("0.0.0.0", 45931))
print("Listening for broadcasts...")
while True:
    msg, addr = sock.recvfrom(1024)
    txt = msg.decode()
    if txt.startswith("DCS_KNBRD19283_PH"):
        print(f"Handshake request received from {addr}")
        tgt_ip = txt.split('|')[1]
        print("Sending response")
        sock.sendto("DCS_KNBRD19283_PC".encode(), (tgt_ip, 45931))
        break