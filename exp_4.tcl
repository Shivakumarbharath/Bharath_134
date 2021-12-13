set ns [new Simulator]
set trf [open prog4.tr w]
$ns trace-all $trf
set namfile [open prog4.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]

set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]

set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5 $n6 $n7" 100Mb 10ms LL Queue/DropTail Channel]


set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
set null [new Agent/Null]
$ns attach-agent $n5 $null
$ns connect $udp $null


set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n7 $sink
$ns connect $tcp $sink

set ftp  [new Application/FTP]
$ftp attach-agent $tcp


proc Finish {} {
global ns namfile trf
$ns flush-trace
exec nam prog4.nam &
close $trf
close $namfile

set tcpsize [exec grep "^r" prog4.tr |  grep "tcp" | tail -n 1 | cut -d " " -f 6]
set numtcp [exec grep "^r" prog4.tr | grep -c "tcp"]
set tcptime 4.0

set udpsize [exec grep "^r" prog4.tr |  grep "cbr" | tail -n 1 | cut -d " " -f 6]
set numudp [exec grep "^r" prog4.tr | grep -c "cbr"]
set udptime 4.0

puts "The Throughput of FTP is "
puts "[expr ($tcpsize * $numtcp)/$tcptime] bytes per seconds"
puts "The Throughput of CBR is "
puts "[expr ($udpsize * $numudp)/$udptime] bytes per seconds"

exit 0
}
$ns at 0.1 "$cbr start"
$ns at 2.0 "$cbr stop"
$ns at 2.5 "$ftp start"
$ns at 4.5 "$ftp stop"
$ns at 5.0 "Finish"
$ns run
