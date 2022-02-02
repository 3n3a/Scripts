import argparse

def dec2bin(n):
    """
        dec2bin
        automatically pads binary numbers for 8bit numbers
    """
    binary_number = bin(n).replace("0b", "")
    if len(binary_number) < 8:
        no_zeroes = 8 - len(binary_number)
        binary_number = (no_zeroes*"0")+binary_number
    return binary_number

def countOccurenceInStr(string, occurrence):
    count = 0
    for i in range(0, len(string)):
        if string[i] == occurrence:
            count += 1
    return count

def bin2ip(bin_ip):
    ip_str = ""

    for i in range(0, len(bin_ip), 8):
        point = ""
        if i < 24:
            point = "."
        ip_part = int(bin_ip[i:i+8], 2)
        ip_str += str(ip_part) + point
    return ip_str


def ip2bin(ip_str, showPoint=True):
  """
        ip2bin
        converts ip address to binary format
  """
  ip_arr = ip_str.split(".")
  ip_out = ""
  for i in range(len(ip_arr)):
    point = "."
    if i == len(ip_arr)-1 or showPoint == False:
        point = ""
    ip_out += dec2bin(int(ip_arr[i])) + point
  return ip_out

def ipClass(ip_str):
    ip_arr = ip_str.split(".")
    first_octet = int(ip_arr[0])
    if first_octet <= 127 and first_octet >= 1:
        return "A"
    elif first_octet >= 128 and first_octet <= 191:
        return "B"
    elif first_octet >= 192 and first_octet <= 223:
        return "C"
    else:
        return "Other Class / Invalid IP"

if __name__=="__main__":
    parser = argparse.ArgumentParser(add_help=True)
    parser.add_argument("ip",
                        type=str,
                        help="The IP Address you want to convert")
    parser.add_argument("sub",
                        type=str,
                        help="The Subnemask for your net")
    args = parser.parse_args()

    sub = args.sub
    sub_bin = ip2bin(sub)
    sub_bin_all = ip2bin(sub, False)

    ip = args.ip
    ip_bin = ip2bin(ip) 
    ip_bin_all = ip2bin(ip, False)
    
    print(
        "Ip-Address: "+ip+"\nIp-Binary: "+ip_bin+"\n"+
        "Subnetmask: "+sub+"\nSubnet Binary: "+sub_bin+"\n"+
        "Class: "+ipClass(ip)
    )

    number_of_ones = countOccurenceInStr(sub_bin_all, "1")
    host_part = ip_bin_all[number_of_ones:32]
    net_part = ip_bin_all[:-(32-number_of_ones)]

    net_id = net_part+len(host_part)*"0"
    host_id = len(net_part)*"0"+host_part
    broadcast_ip = net_part+len(host_part)*"1"

    print("Subnet (CIDR): /"+str(number_of_ones))
    print("Host Part: "+host_part)
    print("Net Part: "+net_part)
    print("Max No. of Hosts: "+str(2**len(host_part)-2))
    print("Net-ID: "+str(bin2ip(net_id)))
    print("Host-ID: "+str(bin2ip(host_id)))
    print("Broadcast Address: "+str(bin2ip(broadcast_ip)))
