set ns [new Simulator]
set trf [open prog3.tr w]
$ns trace-all $trf
set namfile [open prog3.nam w]
$ns namtrace-all $namfile

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

set lan [$ns newLan "$n0 $n1 $n2 $n3 $n4 $n5" 5Mb 10ms LL Queue/DropTail Channel]

set tcp [new Agent/TCP]
$ns attach-agent $n0 $tcp
set ftp [new Application/FTP]
$ftp attach-agent $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n2 $sink
$ns connect $tcp $sink
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null

proc Finish {} {
global ns namfile trf
$ns flush-trace
exec nam prog3.nam &
close $trf
close $namfile
exec echo "The number of packet deops die to collusion is " &
exec grep -c "^d" prog3.tr &
exit 0
}
$ns at 0.1 "$cbr start"
$ns at 2.0 "$ftp start"
$ns at 1.9 "$cbr stop"
$ns at 4.3 "$ftp stop"
$ns at 6.0 "Finish"
$ns run
