$CLIENT_PORT=8372
$SERVER_ADDR="localhost:3000"

$SCANNERD_RESET_SEQ = "reset"

$PAIRED_SCANS = [
	['C','S'],
	['S','P','T','A'],
	['S','P','I','T','A']
]

$TIMEOUT_LIMIT=60
#$SCANNER_FILENAMES=[ '/dev/ttyUSB0' ]
#$SCANNER_FILENAMES=[ '/dev/null' ]
$SCANNER_FILENAMES=[ '/dev/stdin' ]
#$SCANNER_FILENAMES=[ '/dev/ttyS0' ]
