# DO NOT EDIT: IT'S A GENERATED FILE! USE ./configure to REGENERATE!

$TESTS = {"gprs-modem"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"USB GPRS modem",
   :var=>
    {"CHAT_TIMEOUT"=>
      {:type=>"int",
       :comment=>"Timeout for waiting for answer",
       :default=>"5"},
     "ANSWER_ATI"=>
      {:type=>"string", :comment=>"String to get after ATI", :default=>"OK"},
     "DEV"=>
      {:type=>"string",
       :comment=>"Name of device to test",
       :default=>"/dev/ttyUSB0"}},
   :description=>
    "This simple test can determine connected USB modem workability. It sets modem/port speed to 115200bps, checks for proper answer on AT-commands and retrieves it's IMEI number.",
   :version=>"0.1",
   :depends=>["USB", "GPRS Modem"]},
 "memory"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"Memory test: Memtester",
   :var=>
    {"TEST_LOOPS"=>
      {:type=>"int", :comment=>"Number of testing loops", :default=>"3"},
     "LOGTIME"=>
      {:type=>"int",
       :comment=>"Time between progress updates, sec",
       :default=>"120"}},
   :description=>
    "This memory test is performed without reboot, under control of live full-featured OS, using user-space memtester program. Test takes special precautions and tries to lock maximum possible amount of memory for memtester. memtester tests memory using standard read-write-check method using 16 patterns.",
   :version=>"0.1",
   :depends=>["Memory"]},
 "hdd-array"=>
  {:destroys_hdd=>true,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"HDD array stress",
   :var=>
    {"JOBS"=>
      {:type=>"int",
       :comment=>"Number of parallely running jobs during compile",
       :default=>"16"},
     "STRESS_TREE"=>
      {:type=>"string",
       :comment=>"Tarball file containing stress test tree",
       :default=>"linux-2.6.22.5-31-stress.tar.gz"},
     "TESTTIME"=>
      {:type=>"int",
       :comment=>"Total time of HDD array testing, sec",
       :default=>"3600"},
     "LOGTIME"=>
      {:type=>"int",
       :comment=>"Time between progress updates, sec",
       :default=>"120"}},
   :description=>
    "HDD array is a stress test that causes high load on HDD array subsystem. First of all, it creates optimally configured arrays (if possible, otherwise it will use single hard drives) using einarc's raid-wizard-optimal utility. Then it creates a filesystem on each array and unpacks and compiles there a large source tree for a specified time. Test distributes specified test duration among created arrays equally. Compilation, as in hdd-passthrough test, goes with 16 simultaneous jobs (by default). Test would end successfully if there wouldn't be any errors in filesystem creation and source code compilation runs. Usually this test starts after the CPU burning, memory and hdd-passthrough ones, and thus failing of this test (considering successful previous tests) usually identifies a broken RAID controller.",
   :version=>"0.1",
   :depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"]},
 "dhrystone"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"CPU benchmark: Dhrystone",
   :var=>
    {"DURATION"=>
      {:type=>"int", :comment=>"Benchmark duration (sec)", :default=>"300"}},
   :description=>
    "A synthetic computing benchmark that measures CPU integer performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1",
   :depends=>["CPU"]},
 "mencoder"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"Mencoder",
   :var=>
    {"FILE_TO_ENCODE"=>
      {:type=>"string",
       :comment=>"Path to file need to be encoded",
       :default=>"/usr/share/inquisitor/movie.avi"},
     "ENCODE_OPTIONS"=>
      {:type=>"string",
       :comment=>"Encoding options",
       :default=>
        "-ovc lavc -lavcopts vcodec=mpeg4 -oac mp3lame -lameopts vbr=3"}},
   :description=>"Mencoder encoding time benchmark",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"]},
 "usb-flash-drive"=>
  {:destroys_hdd=>true,
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :name=>"USB flash drive",
   :var=>
    {"SIZE"=>
      {:type=>"int",
       :comment=>"Size of test file to be written, Blocksizes",
       :default=>"20"},
     "COUNT"=>
      {:type=>"int",
       :comment=>"There should be this many devices",
       :default=>"2"},
     "BLOCKSIZE"=>
      {:type=>"int",
       :comment=>"Blocksize used for reading and writing by dd, KiB",
       :default=>"1024"}},
   :description=>
    "This test allows to check the working ability of USB ports and/or plugged USB storage devices. A user has to plug the USB storage devices (such as USB flash drives) in every USB port of system under test. A number of USB storage drives is passed then as a COUNT parameter to this test script. First of all, it checks if a required number of USB devices is plugged in: the test won't start if it's not so. This way, a non-working USB port would be diagnosed. The test itself does the following for every detected USB storage device: it writes a number of blocks wit random data (start position is choosen randomly to increase an USB drive's lifetime) and remembers their checksum, then it clears the disk cache and reads these blocks back, calculating checksum. If checksums match, USB device and port work properly. This test also acts as a benchmark: it measures write and read speeds. This metric can be used  to diagnose bad ports/USB devices (due to speed lower than required minimum).",
   :version=>"0.1",
   :depends=>["USB", "USB Mass Storage"]},
 "stream"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"Memory benchmark: STREAM",
   :var=>{},
   :description=>
    "The STREAM benchmark is a simple synthetic benchmark program that measures sustainable memory bandwidth (in MiB/s) and the corresponding computation rate for simple vector kernels. A version written in C language and optimized for single processor systems is used.",
   :version=>"0.1",
   :depends=>["Memory"]},
 "firmware"=>
  {:destroys_hdd=>false,
   :is_interactive=>true,
   :poweroff_during_test=>true,
   :name=>"Firmware reflashing",
   :var=>{},
   :description=>
    "This test is a part of rather complex Inquisitor's firmware reflashing system. This part do following things: 1) Gets a list of components related only to this computer and need to be reflashed. There are needed firmware/flash version and corresponding reflashing image also; 2) Test parses each entity and, depending of component, tries to retrieve it's version (BIOS version through DMI, disk controller's through einarc, for example); 3) Compares it with retrieved from server needed value and if they are not differ - proceed with need component; else - there are two ways: either to reflash it under current GNU/Linux session (to reflash disk controllers with einarc for example), or to ask server to create network bootable file with needed reflasher image; then reboot. After reboot computer will boot up reflasher image (as a rule it is some kind of DOS with batch files and flashers). Server will delete it after boot, to allow Inquisitor booting again. Firmware test will test all of components again and again in cycle until everything's versions will be equal to needed ones. After this test succeeds. Sometimes some component's version can not be detected and human must manually somehow check it and allow test to continue.",
   :version=>"0.1",
   :depends=>["Mainboard", "Disk Controller", "BMC"]},
 "gprs-modem-dialup"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"USB GPRS Modem Dialup",
   :var=>
    {"SPEED"=>{:type=>"int", :comment=>"Line speed", :default=>"115200"},
     "PPPD_USERNAME"=>
      {:type=>"string",
       :comment=>"Cell service provider's pppd username",
       :default=>"mts"},
     "URL"=>
      {:type=>"string",
       :comment=>"URL to download (without http)",
       :default=>
        "img-fotki.yandex.ru/getx/10/photoface.359/sevastopol-foto_34661_L"},
     "UPLOAD_TRIES"=>
      {:type=>"int",
       :comment=>"Number of tries to upload the file",
       :default=>"3"},
     "UPLOAD_URL"=>
      {:type=>"string",
       :comment=>"URL to upload (without http)",
       :default=>""},
     "DOWNLOAD_TRIES"=>
      {:type=>"int",
       :comment=>"Number of tries to download the file",
       :default=>"3"},
     "PPPD_TRIES"=>
      {:type=>"int",
       :comment=>"Number of tries to bring pppd up",
       :default=>"4"},
     "UPLOAD_FILE"=>
      {:type=>"string",
       :comment=>"File to upload",
       :default=>"/etc/ld.so.cache"},
     "MD5"=>
      {:type=>"string",
       :comment=>"MD5 of downloaded file",
       :default=>"ca530886183b06d0047e0655537327aa"},
     "DOWNLOAD_MAX_TIME"=>
      {:type=>"int",
       :comment=>"Timeout for the whole download, sec",
       :default=>"60"},
     "APN"=>
      {:type=>"string",
       :comment=>"Cell service provider's Internet APN",
       :default=>"internet.mts.ru"},
     "UPLOAD_MAX_TIME"=>
      {:type=>"int",
       :comment=>"Timeout for file upload, sec",
       :default=>"120"},
     "DEV"=>
      {:type=>"string",
       :comment=>"Name of device to test",
       :default=>"/dev/ttyUSB0"}},
   :description=>"Test GPRS modem, connected using USB",
   :version=>"0.2",
   :depends=>["USB", "GPRS Modem"]},
 "odd_read"=>
  {:destroys_hdd=>false,
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :name=>"ODD read",
   :var=>
    {"MESH_POINTS"=>
      {:type=>"int",
       :comment=>"Points for meshes for monitoring drive's speed",
       :default=>"1024"},
     "TEST_IMAGE_BLOCKS"=>
      {:type=>"int",
       :comment=>"This images size in blocks (2048 bytes each)",
       :default=>"332800"},
     "FORCE_NON_INTERACTIVE"=>
      {:type=>"boolean",
       :comment=>"Force non-interactive mode for already prepared system",
       :default=>"false"},
     "TEST_IMAGE_HASH"=>
      {:type=>"string",
       :comment=>"Default image for comparison hash",
       :default=>"6fa7786eef2e11d36e8bc1663679f161"}},
   :description=>
    "This test checks for workability and correct optical discs reading of ODDs. It detects if disc is already loaded and tries to run test non-interactively (without any humans nearby). It reads needed number of blocks (trying readcd or dd), calculates their checksums and compares with specified. So, we can determine either drives works fine or not. Also, simultaneously it acts as a monitoring, measuring disc reading speed.",
   :version=>"0.1",
   :depends=>["ODD"]},
 "fdd"=>
  {:destroys_hdd=>false,
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :name=>"FDD read/write",
   :var=>
    {"FLOPPY_SIZE"=>
      {:type=>"int",
       :comment=>"Size of testing floppy, KiB",
       :default=>"1440"}},
   :description=>
    "A simple test to determine wheter the floppy drive work or not. It asks a user to insert a floppy disk into drive, then writes some random data on a diskette, clears the cache, reads the data back and compares it to what was written. Process repeats for every FDD available.",
   :version=>"0.1",
   :depends=>["Floppy"]},
 "net"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"Network interface",
   :var=>
    {"EXCLUDE_MAC"=>
      {:type=>"string",
       :comment=>
        "Exclude NICs with MAC addresses that match this regexp from testing",
       :default=>""},
     "URL"=>
      {:type=>"string",
       :comment=>"Relative to server PORT-URL to be fetched and checked",
       :default=>"3000/test_file"},
     "TIMEOUT"=>
      {:type=>"int",
       :comment=>"Wait timeout while test file retrieving, sec",
       :default=>"15"},
     "MD5"=>
      {:type=>"string",
       :comment=>"MD5 checksum for checking",
       :default=>"805414334eb1d3ff4fdca507ec82098f"}},
   :description=>
    "This test must load every network interface in system and measure it's download speed. Main requirement: all network interfaces must be connected to one common network. Testing sequence is: 1) Detect and remember what interface is default (from what we are booted up (as common)); 2) Consecutively choosing each interface, check if it's MAC address doesn't exist in \"exclude macs\" test parameter, then either skip it, continuing with another one, or continue to test current inteface; 3) Bring testing interface up, configuring network on it and setting it as a default gateway; 4) Bring down all other interfaces; 5) Get test file from specified URL, measuring download speed; 6) Calculate it's checksum and compare with needed (specified by test parameter). Here, test can fail if an error occurs, otherwise it submits speed benchmarking result and continues to test remaining interfaces; 7) After all interfaces (except the first one) are tested, default interface starts testing: there is no real need in it, when we are booting from network - but it is a simplest way to restore default parameters.",
   :version=>"0.2",
   :depends=>["NIC"]},
 "unixbench"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"UnixBench benchmark suite",
   :var=>{},
   :description=>
    "This test is a general-purpose benchmark designed to provide a basic evaluation of the performance of a Unix-like system. It runs a set of tests to evaluate various aspects of system performance, and then generates a set of scores. Here, we are using UnixBench version 5 (multi-CPU aware branch) without 2D/3D graphics benchmarks.",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"]},
 "hdparm"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"HDD benchmark: Hdparm",
   :var=>
    {"AVG_SAMPLES"=>
      {:type=>"int",
       :comment=>"Number of tests per disc to average for result",
       :default=>"5"}},
   :description=>
    "This benchmark runs on all hard drives in the system sequentially. Every hard drive is benchmarked for the buffered speed and the cached speed using basic hdparm -t and -T tests for several times. The results for every HDD are averaged and presented as benchmark results.",
   :version=>"0.1",
   :depends=>["Disk Controller", "HDD"]},
 "gprs-modem-level"=>
  {:destroys_hdd=>false,
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :name=>"USB GPRS modem signal level",
   :var=>
    {"CHAT_TIMEOUT"=>
      {:type=>"int",
       :comment=>"Timeout for waiting for answer",
       :default=>"5"},
     "DEV"=>
      {:type=>"string",
       :comment=>"Name of device to test",
       :default=>"/dev/ttyUSB0"}},
   :description=>
    "This very simple benchmark intended to reset modem and send special AT-command to get signal level. As it (level) can strongly vary, human can repeat this test as much as he want.",
   :version=>"0.1",
   :depends=>["USB", "GPRS Modem"]},
 "hdd-passthrough"=>
  {:destroys_hdd=>true,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"HDD passthrough",
   :var=>
    {"JOBS"=>
      {:type=>"int",
       :comment=>
        "Number of parallely running jobs during stress test tree compile",
       :default=>"16"},
     "DISK_GROUP_SIZE"=>
      {:type=>"int",
       :comment=>"Number of disks per group for testing",
       :default=>"8"},
     "MINIMAL_STRESS_TIME"=>
      {:type=>"int",
       :comment=>"Minimal time of stress testing",
       :default=>"600"},
     "RAMDISK_SIZE"=>
      {:type=>"int",
       :comment=>"Size of memory disk for stress tree building, MB",
       :default=>"400"},
     "STRESS_TREE"=>
      {:type=>"string",
       :comment=>"Tarball file containing stress test tree",
       :default=>"linux-2.6.22.5-31-stress.tar.gz"}},
   :description=>
    "HDD passthrough is a stress test that imposes heavy load on main system components. First, it tries to make all HDDs present in the system to appear as separate device nodes - it checks all available RAID controllers, deletes all arrays / disk groups and creates passthrough devices to access individual HDDs if required. Second, it runs badblocks test on every available HDD, running them simulatenously in groups of 8 HDDs by default. Third, it makes a ramdisk filesystem and starts infinite compilation loop in memory, doing so with 16 simultaneous jobs (by default). Test ends successfully after both 1) minimal required stress time passes, 2) all HDDs are checked with badblocks. Test would fail if any bad blocks would be detected on any HDD. Test will usually hang or crash the system on the unstable hardware.",
   :version=>"0.2",
   :depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"]},
 "odd_write"=>
  {:destroys_hdd=>false,
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :name=>"ODD write",
   :var=>
    {"WRITE_SPEED_FORCE"=>
      {:type=>"boolean",
       :comment=>"Force write speed using",
       :default=>"true"},
     "TEST_IMAGE_BLOCKS"=>
      {:type=>"int",
       :comment=>"This images size in blocks (2048 bytes each)",
       :default=>"332800"},
     "FORCE_NON_INTERACTIVE"=>
      {:type=>"boolean",
       :comment=>"Force non-interactive mode for already prepared system",
       :default=>"false"},
     "TEST_IMAGE_MD5"=>
      {:type=>"string",
       :comment=>"Test image MD5 hash",
       :default=>"ffffffffffffffffffffffffffffffff"},
     "WRITE_MESSAGE"=>
      {:type=>"string",
       :comment=>"Message to print when test will start",
       :default=>"Writing test disc"},
     "WRITE_SPEED"=>
      {:type=>"int",
       :comment=>"Default write speed if it won't detect",
       :default=>"10"},
     "TEST_IMAGE"=>
      {:type=>"string",
       :comment=>"ISO image path (absolute or relative)",
       :default=>"iso/testimage.iso"}},
   :description=>
    "This test is needed to record discs and at the same time to check corectness of this operation. It can detect if rewritable/recordable media is already inserted and tries to continue non-interactively. After detecting maximal writing speed (it can be forced by an option), blanking if it is rewritable non-blank media, it records specified ISO image. Then, it reads it to compare it's checksum with original one. After all of this we can make a conclusion about drives quality.",
   :version=>"0.1",
   :depends=>["ODD"]},
 "hdd-smart"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"HDD SMART",
   :var=>
    {"LOGTIME"=>
      {:type=>"int",
       :comment=>"Time between progress updates, sec",
       :default=>"120"}},
   :description=>
    "Simple test for SMART capable hard drives. At first it tries to find is there any SMART capable and correctly working with it drives. Test uses standard smartmontools package. Next, it starts long time full SMART testing on every capable drive and waits for their completion. If everything in SMART log seems good tests passes successfully.",
   :version=>"0.1",
   :depends=>["HDD"]},
 "cpu"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"CPU burn",
   :var=>
    {"TESTTIME"=>
      {:type=>"int",
       :comment=>"Total time of CPU testing, sec",
       :default=>"1800"}},
   :description=>
    "Basic CPU burn test makes the CPUs execute instructions that rapidly increase processor's temperature in an infinite loop. Test makes special care about used instruction set (to make load as high as possible).",
   :version=>"0.1",
   :depends=>["CPU"]},
 "whetstone"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"CPU benchmark: Whetstone",
   :var=>{"LOOPS"=>{:type=>"int", :comment=>"Loop count", :default=>"200000"}},
   :description=>
    "A synthetic computing benchmark that measures CPU floating-point performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1",
   :depends=>["CPU"]},
 "usb-device"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"USB presence",
   :var=>
    {"IDVENDOR"=>
      {:type=>"string",
       :comment=>
        "Filter in only devices with this idVendor (match all if empty)",
       :default=>"0403"},
     "COUNT"=>
      {:type=>"int",
       :comment=>"There should be this many devices",
       :default=>"1"},
     "IDPRODUCT"=>
      {:type=>"string",
       :comment=>
        "Filter in only devices with this idProduct (match all if empty)",
       :default=>"6001"}},
   :description=>
    "Tests the presence of designated USB devices. It checks for a count of USB devices that match specified idVendor and idProduct and gives a success if they're equal to COUNT parameter or failure if they're not.",
   :version=>"0.1",
   :depends=>["USB"]},
 "flash"=>
  {:destroys_hdd=>true,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"Flash disk",
   :var=>
    {"SIZE_LIMIT"=>
      {:type=>"int",
       :comment=>"That is less than this amount is an IDE flash, MiB",
       :default=>"2048"}},
   :description=>"Flash disk badblocks test",
   :version=>"0.1"},
 "bonnie"=>
  {:destroys_hdd=>true,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"HDD benchmark: Bonnie",
   :var=>{},
   :description=>
    "This test uses bonnie++ benchmark to test hard drives performance. For every hard drive in a system, test formats it using ext2 filesystem and then runs bonnie++ benchmark. Test measures the IO throughput in situations that simulate some types of database applications. It uses a single test file size to twice the amount of RAM. Benchmark reports output/rewrite/input of char/block speed and CPU load.",
   :version=>"0.1",
   :depends=>["HDD"]},
 "db_comparison"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"DB to Detects comparison",
   :var=>{},
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
     "Video",
     "ODD",
     "GPRS Modem",
     "USB Mass Storage"]},
 "bytemark"=>
  {:destroys_hdd=>false,
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :name=>"BYTEmark benchmark suite",
   :var=>{},
   :description=>
    "The BYTEmark benchmark test suite is used to determine how the processor, its caches and coprocessors influence overall system performance. Its measurements can indicate problems with the processor subsystem and (since the processor is a major influence on overall system performance) give us an idea of how well a given system will perform. The BYTEmark test suite is especially valuable since it lets us directly compare computers with different processors and operating systems. The code used in BYTEmark tests simulates some of the real-world operations used by popular office and technical applications. Tests include: numeric and string sort, bitfield working, fourier and assignment manipulations, huffman, IDEA, LU decomposition, neural net.",
   :version=>"0.1",
   :depends=>["CPU", "Memory", "Mainboard"]}}

$MONITORINGS = {"cpu-vcore-ipmi"=>
  {:name=>"CPU core voltage (ipmi)",
   :measurement=>"voltage",
   :description=>
    "This monitoring uses ipmitool for getting CPU's core voltage.",
   :id=>3},
 "cpu-temp-ipmi"=>
  {:name=>"CPU temperature (ipmi)",
   :measurement=>"temperature",
   :description=>
    "This monitoring uses ipmitool for getting CPU's temperature.",
   :id=>1},
 "odd-read"=>
  {:name=>"ODD read speed",
   :measurement=>"speed",
   :description=>
    "This is not a real monitoring: it runs only once during odd_read test, that submits drive speed. You can view actual code in client/test/odd_read in generate_speed_results function.",
   :id=>6},
 "hdd-smart"=>
  {:name=>"HDD temperature",
   :measurement=>"temperature",
   :description=>
    "This monitoring uses hard drive's SMART to get its temperature.",
   :id=>5},
 "cpu-temp-sensors"=>
  {:name=>"CPU temperature (sensors)",
   :measurement=>"temperature",
   :description=>"This monitoring uses sensors for getting CPU's temperature.",
   :id=>2},
 "cpu-vcore-sensors"=>
  {:name=>"CPU core voltage (sensors)",
   :measurement=>"voltage",
   :description=>"This monitoring uses sensors for getting CPU's vcore.",
   :id=>4}}

$DETECTS = {"osd"=>
  {:name=>"OSD detect",
   :description=>
    "Detect optical disk drives using hal-device and try to guess correct vendor name.",
   :depends=>["OSD"]},
 "memory"=>
  {:name=>"Memory detect",
   :description=>"Detect DIMMs using SPD, IPMI, DMI, /proc.",
   :depends=>["Memory"]},
 "tape"=>
  {:name=>"Tape detect",
   :description=>"Detect tape drives using hal-device.",
   :depends=>["Tape drive"]},
 "bmc"=>
  {:name=>"BMC detect",
   :description=>"Get BMC information through ipmitool.",
   :depends=>["BMC"]},
 "ipmi"=>
  {:name=>"IPMI parser",
   :description=>"Get some devices info using ipmitool.",
   :depends=>
    ["Chassis", "Mainboard", "Platform", "Power Supply", "SCSI Backplane"]},
 "usb"=>
  {:name=>"USB devices detect",
   :description=>"Detect some devices that plugged into USB bus.",
   :depends=>["USB"]},
 "controller"=>
  {:name=>"Disk controller detect",
   :description=>
    "Detect disk controllers through einarc and hal-device with required priority.",
   :depends=>["Disk Controller"]},
 "hdd"=>
  {:name=>"HDD detect",
   :description=>"Detect hard drives using einarc, smartctl and hal-device.",
   :depends=>["HDD"]},
 "cpu"=>
  {:name=>"CPU detect",
   :description=>"Detect CPUs using /proc/cpuinfo.",
   :depends=>["CPU"]},
 "floppy"=>
  {:name=>"Floppy detect",
   :description=>"Detect floppy drives using hal-device.",
   :depends=>["Floppy"]},
 "00lshw-to-xml"=>
  {:name=>"lshw to xml converter",
   :description=>"Convert lshw output to required XML document.",
   :depends=>["Video", "NIC", "Fire Wire"]}}

