# DO NOT EDIT: IT'S A GENERATED FILE! USE ./configure to REGENERATE!

$TESTS = {"gprs-modem"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"CHAT_TIMEOUT"=>
      {:type=>"int",
       :default=>"5",
       :comment=>"Timeout for waiting for answer"},
     "ANSWER_ATI"=>
      {:type=>"string", :default=>"OK", :comment=>"String to get after ATI"},
     "DEV"=>
      {:type=>"string",
       :default=>"/dev/ttyUSB0",
       :comment=>"Name of device to test"}},
   :name=>"USB GPRS modem",
   :description=>"Test GPRS modem, connected using USB",
   :version=>"0.1",
   :destroys_hdd=>false},
 "memory"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"TEST_LOOPS"=>
      {:type=>"int", :default=>"3", :comment=>"Number of testing loops"},
     "LOGTIME"=>
      {:type=>"int",
       :default=>"120",
       :comment=>"Time between progress updates, sec"}},
   :name=>"Memory test: memtester",
   :description=>
    "This memory test is performed without reboot, under control of live full-featured OS, using user-space memtester program. Test takes special precautions and tries to lock maximum possible amount of memory for memtester. memtester tests memory using standard read-write-check method using 16 patterns.",
   :version=>"0.1",
   :depends=>["Memory"],
   :destroys_hdd=>false},
 "hdd-array"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"JOBS"=>
      {:type=>"int",
       :default=>"16",
       :comment=>"Number of parallely running jobs during compile"},
     "STRESS_TREE"=>
      {:type=>"string",
       :default=>"linux-2.6.22.5-31-stress.tar.gz",
       :comment=>"Tarball file containing stress test tree"},
     "TESTTIME"=>
      {:type=>"int",
       :default=>"3600",
       :comment=>"Total time of HDD array testing, sec"},
     "LOGTIME"=>
      {:type=>"int",
       :default=>"120",
       :comment=>"Time between progress updates, sec"}},
   :name=>"HDD array stress",
   :description=>
    "HDD array is a stress test that causes high load on HDD array subsystem. First of all, it creates optimally configured arrays (if possible, otherwise it will use single hard drives) using einarc's raid-wizard-optimal utility. Then it creates a filesystem on each array and unpacks and compiles there a large source tree for a specified time. Test distributes specified test duration among created arrays equally. Compilation, as in hdd-passthrough test, goes with 16 simultaneous jobs (by default). Test would end successfully if there wouldn't be any errors in filesystem creation and source code compilation runs. Usually this test starts after the CPU burning, memory and hdd-passthrough ones, and thus failing of this test (considering successful previous tests) usually identifies a broken RAID controller.",
   :version=>"0.1",
   :depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"],
   :destroys_hdd=>true},
 "mencoder"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"FILE_TO_ENCODE"=>
      {:type=>"string",
       :default=>"/usr/share/inquisitor/movie.avi",
       :comment=>"Path to file need to be encoded"},
     "ENCODE_OPTIONS"=>
      {:type=>"string",
       :default=>
        "-ovc lavc -lavcopts vcodec=mpeg4 -oac mp3lame -lameopts vbr=3",
       :comment=>"Encoding options"}},
   :name=>"Mencoder",
   :description=>"Mencoder encoding time benchmark",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"],
   :destroys_hdd=>false},
 "stream"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :name=>"Stream",
   :description=>
    "The STREAM benchmark is a simple synthetic benchmark program that measures sustainable memory bandwidth (in MiB/s) and the corresponding computation rate for simple vector kernels. A version written in C language and optimized for single processor systems is used.",
   :version=>"0.1",
   :depends=>["Memory"],
   :destroys_hdd=>false},
 "dhrystone"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"DURATION"=>
      {:type=>"int", :default=>"30", :comment=>"Benchmark duration (sec)"}},
   :name=>"Dhrystone",
   :description=>
    "A synthetic computing benchmark that measures CPU integer performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1",
   :depends=>["CPU"],
   :destroys_hdd=>false},
 "usb-flash-drive"=>
  {:is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"SIZE"=>
      {:type=>"int",
       :default=>"20",
       :comment=>"Size of test file to be written, Blocksizes"},
     "COUNT"=>
      {:type=>"int",
       :default=>"2",
       :comment=>"There should be this many devices"},
     "BLOCKSIZE"=>
      {:type=>"int",
       :default=>"1024",
       :comment=>"Blocksize used for reading and writing by dd, KiB"}},
   :name=>"USB Flash Drive",
   :description=>
    "This test allows to check the working ability of USB ports and/or plugged USB storage devices. A user has to plug the USB storage devices (such as USB flash drives) in every USB port of system under test. A number of USB storage drives is passed then as a COUNT parameter to this test script. First of all, it checks if a required number of USB devices is plugged in: the test won't start if it's not so. This way, a non-working USB port would be diagnosed. The test itself does the following for every detected USB storage device: it writes a number of blocks wit random data (start position is choosen randomly to increase an USB drive's lifetime) and remembers their checksum, then it clears the disk cache and reads these blocks back, calculating checksum. If checksums match, USB device and port work properly. This test also acts as a benchmark: it measures write and read speeds. This metric can be used  to diagnose bad ports/USB devices (due to speed lower than required minimum).",
   :version=>"0.1",
   :depends=>["USB"],
   :destroys_hdd=>true},
 "firmware"=>
  {:is_interactive=>false,
   :poweroff_during_test=>true,
   :var=>{},
   :name=>"Firmware reflashing",
   :description=>"Firmware reflashing",
   :version=>"0.1",
   :depends=>["Mainboard", "Disk Controller"],
   :destroys_hdd=>false},
 "odd_read"=>
  {:is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"MESH_POINTS"=>
      {:type=>"int",
       :default=>"1024",
       :comment=>"Points for meshes for monitoring drive's speed"},
     "TEST_IMAGE_BLOCKS"=>
      {:type=>"int",
       :default=>"332800",
       :comment=>"This images size in blocks (2048 bytes each)"},
     "FORCE_NON_INTERACTIVE"=>
      {:type=>"boolean",
       :default=>"false",
       :comment=>"Force non-interactive mode for already prepared system"},
     "TEST_IMAGE_HASH"=>
      {:type=>"string",
       :default=>"6fa7786eef2e11d36e8bc1663679f161",
       :comment=>"Default image for comparison hash"}},
   :name=>"ODD read",
   :description=>"Optical Disc Drive read test",
   :version=>"0.1",
   :depends=>["ODD"],
   :destroys_hdd=>false},
 "gprs-modem-dialup"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SPEED"=>{:type=>"int", :default=>"115200", :comment=>"Line speed"},
     "PPPD_USERNAME"=>
      {:type=>"string",
       :default=>"mts",
       :comment=>"Cell service provider's pppd username"},
     "URL"=>
      {:type=>"string",
       :default=>
        "img-fotki.yandex.ru/getx/10/photoface.359/sevastopol-foto_34661_L",
       :comment=>"URL to download (without http)"},
     "UPLOAD_TRIES"=>
      {:type=>"int",
       :default=>"3",
       :comment=>"Number of tries to upload the file"},
     "UPLOAD_URL"=>
      {:type=>"string",
       :default=>"",
       :comment=>"URL to upload (without http)"},
     "DOWNLOAD_TRIES"=>
      {:type=>"int",
       :default=>"3",
       :comment=>"Number of tries to download the file"},
     "PPPD_TRIES"=>
      {:type=>"int",
       :default=>"4",
       :comment=>"Number of tries to bring pppd up"},
     "UPLOAD_FILE"=>
      {:type=>"string",
       :default=>"/etc/ld.so.cache",
       :comment=>"File to upload"},
     "MD5"=>
      {:type=>"string",
       :default=>"ca530886183b06d0047e0655537327aa",
       :comment=>"MD5 of downloaded file"},
     "DOWNLOAD_MAX_TIME"=>
      {:type=>"int",
       :default=>"60",
       :comment=>"Timeout for the whole download, sec"},
     "APN"=>
      {:type=>"string",
       :default=>"internet.mts.ru",
       :comment=>"Cell service provider's Internet APN"},
     "UPLOAD_MAX_TIME"=>
      {:type=>"int",
       :default=>"120",
       :comment=>"Timeout for file upload, sec"},
     "DEV"=>
      {:type=>"string",
       :default=>"/dev/ttyUSB0",
       :comment=>"Name of device to test"}},
   :name=>"USB GPRS Modem Dialup",
   :description=>"Test GPRS modem, connected using USB",
   :version=>"0.2",
   :destroys_hdd=>false},
 "fdd"=>
  {:is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"FLOPPY_SIZE"=>
      {:type=>"int",
       :default=>"1440",
       :comment=>"Size of testing floppy, KiB"}},
   :name=>"FDD read/write",
   :description=>
    "A simple test to determine wheter the floppy drive work or not. It asks a user to insert a floppy disk into drive, then writes some random data on a diskette, clears the cache, reads the data back and compares it to what was written. Process repeats for every FDD available.",
   :version=>"0.1",
   :depends=>["Floppy"],
   :destroys_hdd=>false},
 "net"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"EXCLUDE_MAC"=>
      {:type=>"string",
       :default=>"",
       :comment=>
        "Exclude NICs with MAC addresses that match this regexp from testing"},
     "URL"=>
      {:type=>"string",
       :default=>"3000/test_file",
       :comment=>"Relative to server PORT:URL to be fetched and checked"},
     "TIMEOUT"=>
      {:type=>"int",
       :default=>"15",
       :comment=>"Wait timeout while test file retrieving, sec"},
     "MD5"=>
      {:type=>"string",
       :default=>"805414334eb1d3ff4fdca507ec82098f",
       :comment=>"MD5 checksum for checking"}},
   :name=>"Network interface",
   :description=>
    "This test must load every network interface in system and measure it's download speed. Main requirement: all network interfaces must be connected to one common network. Testing sequence is: 1) Detect and remember what interface is default (from what we are booted up (as common)); 2) Consecutively choosing each interface, check if it's MAC address doesn't exist in \"exclude macs\" test parameter, then either skip it, continuing with another one, or continue to test current inteface; 3) Bring testing interface up, configuring network on it and setting it as a default gateway; 4) Bring down all other interfaces; 5) Get test file from specified URL, measuring download speed; 6) Calculate it's checksum and compare with needed (specified by test parameter). Here, test can fail if an error occurs, otherwise it submits speed benchmarking result and continues to test remaining interfaces; 7) After all interfaces (except the first one) are tested, default interface starts testing: there is no real need in it, when we are booting from network - but it is a simplest way to restore default parameters.",
   :version=>"0.2",
   :depends=>["NIC"],
   :destroys_hdd=>false},
 "odd_write"=>
  {:is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"WRITE_SPEED_FORCE"=>
      {:type=>"boolean",
       :default=>"true",
       :comment=>"Force write speed using"},
     "TEST_IMAGE_BLOCKS"=>
      {:type=>"int",
       :default=>"332800",
       :comment=>"This images size in blocks (2048 bytes each)"},
     "FORCE_NON_INTERACTIVE"=>
      {:type=>"boolean",
       :default=>"false",
       :comment=>"Force non-interactive mode for already prepared system"},
     "TEST_IMAGE_MD5"=>
      {:type=>"string",
       :default=>"ffffffffffffffffffffffffffffffff",
       :comment=>"Test image MD5 hash"},
     "WRITE_MESSAGE"=>
      {:type=>"string",
       :default=>"Writing test disc",
       :comment=>"Message to print when test will start"},
     "WRITE_SPEED"=>
      {:type=>"int",
       :default=>"10",
       :comment=>"Default write speed if it won't detect"},
     "TEST_IMAGE"=>
      {:type=>"string",
       :default=>"iso/testimage.iso",
       :comment=>"ISO image path (absolute or relative)"}},
   :name=>"odd_write",
   :description=>"Optical Disc Drive write test",
   :version=>"0.1",
   :depends=>["ODD"],
   :destroys_hdd=>false},
 "gprs-modem-level"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"CHAT_TIMEOUT"=>
      {:type=>"int",
       :default=>"5",
       :comment=>"Timeout for waiting for answer"},
     "DEV"=>
      {:type=>"string",
       :default=>"/dev/ttyUSB0",
       :comment=>"Name of device to test"}},
   :name=>"USB GPRS modem signal level",
   :description=>
    "Measure signal level, received by GPRS modem, connected via USB",
   :version=>"0.1",
   :destroys_hdd=>false},
 "hdparm"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"AVG_SAMPLES"=>
      {:type=>"int",
       :default=>"5",
       :comment=>"Number of tests per disc to average for result"}},
   :name=>"HDD speed benchmark: hdparm",
   :description=>
    "This benchmark runs on all hard drives in the system sequentially. Every hard drive is benchmarked for the buffered speed and the cached speed using basic hdparm -t and -T tests for several times. The results for every HDD are averaged and presented as benchmark results.",
   :version=>"0.1",
   :depends=>["Disk Controller", "HDD"],
   :destroys_hdd=>false},
 "unixbench"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :name=>"Unixbench",
   :description=>"UNIX Bench Multi-CPU benchmark",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"],
   :destroys_hdd=>false},
 "hdd-passthrough"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"JOBS"=>
      {:type=>"int",
       :default=>"16",
       :comment=>
        "Number of parallely running jobs during stress test tree compile"},
     "DISK_GROUP_SIZE"=>
      {:type=>"int",
       :default=>"8",
       :comment=>"Number of disks per group for testing"},
     "MINIMAL_STRESS_TIME"=>
      {:type=>"int",
       :default=>"600",
       :comment=>"Minimal time of stress testing"},
     "RAMDISK_SIZE"=>
      {:type=>"int",
       :default=>"400",
       :comment=>"Size of memory disk for stress tree building, MB"},
     "STRESS_TREE"=>
      {:type=>"string",
       :default=>"linux-2.6.22.5-31-stress.tar.gz",
       :comment=>"Tarball file containing stress test tree"}},
   :name=>"HDD passthrough",
   :description=>
    "HDD passthrough is a stress test that imposes heavy load on main system components. First, it tries to make all HDDs present in the system to appear as separate device nodes - it checks all available RAID controllers, deletes all arrays / disk groups and creates passthrough devices to access individual HDDs if required. Second, it runs badblocks test on every available HDD, running them simulatenously in groups of 8 HDDs by default. Third, it makes a ramdisk filesystem and starts infinite compilation loop in memory, doing so with 16 simultaneous jobs (by default). Test ends successfully after both 1) minimal required stress time passes, 2) all HDDs are checked with badblocks. Test would fail if any bad blocks would be detected on any HDD. Test will usually hang or crash the system on the unstable hardware.",
   :version=>"0.1",
   :depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"],
   :destroys_hdd=>true},
 "cpu"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"TESTTIME"=>
      {:type=>"int",
       :default=>"1800",
       :comment=>"Total time of CPU testing, sec"}},
   :name=>"CPU burn",
   :description=>
    "Basic CPU burn test makes the CPUs execute instructions that rapidly increase processor's temperature in an infinite loop. Test makes special care about used instruction set (to make load as high as possible).",
   :version=>"0.1",
   :depends=>["CPU"],
   :destroys_hdd=>false},
 "usb-device"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"IDVENDOR"=>
      {:type=>"string",
       :default=>"0403",
       :comment=>
        "Filter in only devices with this idVendor (match all if empty)"},
     "COUNT"=>
      {:type=>"int",
       :default=>"1",
       :comment=>"There should be this many devices"},
     "IDPRODUCT"=>
      {:type=>"string",
       :default=>"6001",
       :comment=>
        "Filter in only devices with this idProduct (match all if empty)"}},
   :name=>"USB presence",
   :description=>
    "Tests the presence of designated USB devices. It checks for a count of USB devices that match specified idVendor and idProduct and gives a success if they're equal to COUNT parameter or failure if they're not.",
   :version=>"0.1",
   :depends=>["USB"],
   :destroys_hdd=>false},
 "bonnie"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :name=>"Bonnie",
   :description=>
    "This test uses bonnie++ benchmark to test hard drives performance. For every hard drive in a system, test formats it using ext2 filesystem and then runs bonnie++ benchmark. Test measures the IO throughput in situations that simulate some types of database applications. It uses a single test file size to twice the amount of RAM. Benchmark reports output/rewrite/input of char/block speed and CPU load.",
   :version=>"0.1",
   :depends=>["HDD"],
   :destroys_hdd=>true},
 "whetstone"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{"LOOPS"=>{:type=>"int", :default=>"20000", :comment=>"Loop count"}},
   :name=>"Whetstone",
   :description=>
    "A synthetic computing benchmark that measures CPU floating-point performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1",
   :depends=>["CPU"],
   :destroys_hdd=>false},
 "flash"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SIZE_LIMIT"=>
      {:type=>"int",
       :default=>"2048",
       :comment=>"That is less than this amount is an IDE flash, MiB"}},
   :name=>"Flash disk",
   :description=>"Flash disk badblocks test",
   :version=>"0.1",
   :destroys_hdd=>true},
 "db_comparison"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :name=>"DB to Detects comparison",
   :description=>
    "Pauses testing until comparison has been completed on the application server.",
   :version=>"0.1",
   :depends=>
    ["BMC",
     "CPU",
     "Chassis",
     "Disk Controller",
     "Floppy",
     "HDD",
     "Mainboard",
     "Memory",
     "NIC",
     "OSD",
     "Platform",
     "USB",
     "Video"],
   :destroys_hdd=>false},
 "bytemark"=>
  {:is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :name=>"BYTEmark",
   :description=>"BYTEmark native mode benchmark",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"],
   :destroys_hdd=>false}}

$MONITORINGS = {"cpu-vcore-ipmi"=>{:title=>"CPU-VCORE(ipmi)", :measurement=>"vcore", :id=>3},
 "cpu-temp-ipmi"=>{:title=>"CPU-TEMP(ipmi)", :measurement=>"temp", :id=>1},
 "odd-read"=>{:title=>"ODD-READ", :measurement=>"speed", :id=>6},
 "hdd-smart"=>{:title=>"HDD-SMART", :measurement=>"temp", :id=>5},
 "cpu-temp-sensors"=>
  {:title=>"CPU-TEMP(sensors)", :measurement=>"temp", :id=>2},
 "cpu-vcore-sensors"=>
  {:title=>"CPU-VCORE(sensors)", :measurement=>"vcore", :id=>4}}

