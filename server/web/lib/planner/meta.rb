# DO NOT EDIT: IT'S A GENERATED FILE! USE ./configure to REGENERATE!

$TESTS = {"gprs-modem"=>
  {:depends=>["USB", "GPRS Modem"],
   :destroys_hdd=>false,
   :name=>"USB GPRS modem",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"CHAT_TIMEOUT"=>
      {:default=>"5",
       :type=>"int",
       :comment=>"Timeout for waiting for answer"},
     "ANSWER_ATI"=>
      {:default=>"OK", :type=>"string", :comment=>"String to get after ATI"},
     "DEV"=>
      {:default=>"/dev/ttyUSB0",
       :type=>"string",
       :comment=>"Name of device to test"}},
   :description=>
    "This simple test can determine connected USB modem workability. It sets modem/port speed to 115200bps, checks for proper answer on AT-commands and retrieves it's IMEI number.",
   :version=>"0.1"},
 "dd"=>
  {:depends=>["HDD", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"DD",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"OF"=>
      {:default=>"sda",
       :type=>"string",
       :comment=>"Target device name that will be overwritten"},
     "COUNT"=>
      {:default=>"1024",
       :type=>"int",
       :comment=>
        "Number of blocks to be written. If zero is specified then this parameter won't be used"},
     "BLOCKSIZE"=>{:default=>"1024", :type=>"int", :comment=>"Blocksize, KiB"},
     "IF"=>
      {:default=>"raw_disk_image",
       :type=>"string",
       :comment=>
        "Either absolute or relative path to source raw disk image to be written, or URL to download"},
     "SKIP"=>
      {:default=>"0", :type=>"int", :comment=>"Number of blocks to skip"},
     "COMPRESSION"=>
      {:default=>"none",
       :type=>"string",
       :comment=>
        "What compression is used. gzip, bzip2 or lzma can be chosen"}},
   :description=>
    "Actually this is not a real test. It can be used to write prepared raw disk image using DD utility.",
   :version=>"0.2"},
 "iozone"=>
  {:depends=>["HDD"],
   :destroys_hdd=>true,
   :name=>"HDD benchmark: IOzone",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"TEST_FILE_SIZE"=>
      {:default=>"0",
       :type=>"int",
       :comment=>
        "Size of test file, MiB. If set to zero - double memory amount size will be used"}},
   :description=>
    "This benchmark measures the speed of sequential I/O to actual files. It generates and measures a variety of file operations.",
   :version=>"0.1"},
 "torrent-upload"=>
  {:depends=>["HDD", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"Torrent upload",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SEED_AFTER"=>
      {:default=>"true",
       :type=>"bool",
       :comment=>"Seed after successfull test finishing?"},
     "TORRENT"=>
      {:default=>"test.torrent",
       :type=>"string",
       :comment=>
        "Either absolute or relative path to .torrent file. Be sure that tracker is available from network"},
     "TARGET"=>
      {:default=>"/dev/sda",
       :type=>"string",
       :comment=>"Target device name that will be overwritten"}},
   :description=>
    "This test uses BitTorrent client to download specified torrent. It uses Enhanced CTorrent client. With its modified version it can write directly on block devices.",
   :version=>"0.1"},
 "memory"=>
  {:depends=>["Memory"],
   :destroys_hdd=>false,
   :name=>"Memory test: Memtester",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"TEST_LOOPS"=>
      {:default=>"1", :type=>"int", :comment=>"Number of testing loops"},
     "LOGTIME"=>
      {:default=>"120",
       :type=>"int",
       :comment=>"Time between progress updates, sec"}},
   :description=>
    "This memory test is performed without reboot, under control of live full-featured OS, using user-space memtester program. Test takes special precautions and tries to lock maximum possible amount of memory for memtester. memtester tests memory using standard read-write-check method using 16 patterns.",
   :version=>"0.1"},
 "boot_from_image"=>
  {:depends=>[],
   :destroys_hdd=>false,
   :name=>"Boot from image",
   :is_interactive=>false,
   :poweroff_during_test=>true,
   :var=>
    {"IMAGE"=>
      {:default=>"boot_image.img",
       :type=>"string",
       :comment=>"Image to boot from after rebooting"}},
   :description=>
    "This is not real test. It will always succeed if file is available for booting. Can be used to force single loading from image file without any checks about its success finishing.",
   :version=>"0.1"},
 "hdd-array"=>
  {:depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"HDD array stress",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"JOBS"=>
      {:default=>"16",
       :type=>"int",
       :comment=>"Number of parallely running jobs during compile"},
     "MINIMAL_DRIVE_SIZE"=>
      {:default=>"2048",
       :type=>"int",
       :comment=>"That is less than this amount is an flash device, MiB"},
     "STRESS_TREE"=>
      {:default=>"linux-2.6.22.5-31-stress.tar.gz",
       :type=>"string",
       :comment=>"Tarball file containing stress test tree"},
     "TESTTIME"=>
      {:default=>"3600",
       :type=>"int",
       :comment=>"Total time of HDD array testing, sec"},
     "LOGTIME"=>
      {:default=>"120",
       :type=>"int",
       :comment=>"Time between progress updates, sec"}},
   :description=>
    "HDD array is a stress test that causes high load on HDD array subsystem. First of all, it creates optimally configured arrays (if possible, otherwise it will use single hard drives) using einarc's raid-wizard-optimal utility. Then it creates a filesystem on each array and unpacks and compiles there a large source tree for a specified time. Test distributes specified test duration among created arrays equally. Compilation, as in hdd-passthrough test, goes with 16 simultaneous jobs (by default). Test would end successfully if there wouldn't be any errors in filesystem creation and source code compilation runs. Usually this test starts after the CPU burning, memory and hdd-passthrough ones, and thus failing of this test (considering successful previous tests) usually identifies a broken RAID controller.",
   :version=>"0.1"},
 "usb-flash-drive"=>
  {:depends=>["USB", "USB Mass Storage"],
   :destroys_hdd=>true,
   :name=>"USB flash drive",
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"SIZE"=>
      {:default=>"20",
       :type=>"int",
       :comment=>"Size of test file to be written, Blocksizes"},
     "COUNT"=>
      {:default=>"2",
       :type=>"int",
       :comment=>"There should be this many devices"},
     "BLOCKSIZE"=>
      {:default=>"1024",
       :type=>"int",
       :comment=>"Blocksize used for reading and writing by dd, KiB"}},
   :description=>
    "This test allows to check the working ability of USB ports and/or plugged USB storage devices. A user has to plug the USB storage devices (such as USB flash drives) in every USB port of system under test. A number of USB storage drives is passed then as a COUNT parameter to this test script. First of all, it checks if a required number of USB devices is plugged in: the test won't start if it's not so. This way, a non-working USB port would be diagnosed. The test itself does the following for every detected USB storage device: it writes a number of blocks wit random data (start position is choosen randomly to increase an USB drive's lifetime) and remembers their checksum, then it clears the disk cache and reads these blocks back, calculating checksum. If checksums match, USB device and port work properly. This test also acts as a benchmark: it measures write and read speeds. This metric can be used  to diagnose bad ports/USB devices (due to speed lower than required minimum).",
   :version=>"0.1"},
 "dhrystone"=>
  {:depends=>["CPU"],
   :destroys_hdd=>false,
   :name=>"CPU benchmark: Dhrystone",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"DURATION"=>
      {:default=>"300", :type=>"int", :comment=>"Benchmark duration (sec)"}},
   :description=>
    "A synthetic computing benchmark that measures CPU integer performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1"},
 "stream"=>
  {:depends=>["Memory"],
   :destroys_hdd=>false,
   :name=>"Memory benchmark: STREAM",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :description=>
    "The STREAM benchmark is a simple synthetic benchmark program that measures sustainable memory bandwidth (in MiB/s) and the corresponding computation rate for simple vector kernels. A version written in C language and optimized for single processor systems is used.",
   :version=>"0.1"},
 "stress-compress"=>
  {:depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"Stress compression",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"JOBS"=>
      {:default=>"16",
       :type=>"int",
       :comment=>
        "Number of parallely running jobs during stress test compression/decompression"},
     "SYNCTIME"=>
      {:default=>"2", :type=>"int", :comment=>"Sync time period, sec"},
     "STRESS_TREE"=>
      {:default=>"linux-2.6.22.5-31-stress.tar.gz",
       :type=>"string",
       :comment=>"Gzipped tarball file containing stress test tree"},
     "TESTTIME"=>
      {:default=>"600",
       :type=>"int",
       :comment=>"Total time of stress testing, sec"}},
   :description=>
    "This test runs many jobs on a hard drive simultaneously with background syncer. Each jobs performs compression/decompression together with taring/untaring of a big archive (Linux source code for example) in infinite loop. Syncer simply makes sync call each specified number of seconds. After specified time amount passed all jobs will be killed with syncer. Test will post benchmark results and successfully finish.",
   :version=>"0.1"},
 "firmware"=>
  {:depends=>["Mainboard", "Disk Controller", "BMC"],
   :destroys_hdd=>false,
   :name=>"Firmware reflashing",
   :is_interactive=>true,
   :poweroff_during_test=>true,
   :var=>
    {"FORCE_FIRMWARES_LIST"=>
      {:default=>"",
       :type=>"string",
       :comment=>
        "Forced firmwares list over that sended by server. Newlines replaced by twice doubledots"}},
   :description=>
    "This test is a part of rather complex Inquisitor's firmware reflashing system. This part do following things: 1) Gets a list of components related only to this computer and need to be reflashed. There are needed firmware/flash version and corresponding reflashing image also; 2) Test parses each entity and, depending of component, tries to retrieve it's version (BIOS version through DMI, disk controller's through einarc, for example); 3) Compares it with retrieved from server needed value and if they are not differ - proceed with need component; else - there are two ways: either to reflash it under current GNU/Linux session (to reflash disk controllers with einarc for example), or to ask server to create network bootable file with needed reflasher image; then reboot. After reboot computer will boot up reflasher image (as a rule it is some kind of DOS with batch files and flashers). Server will delete it after boot, to allow Inquisitor booting again. Firmware test will test all of components again and again in cycle until everything's versions will be equal to needed ones. After this test succeeds. Sometimes some component's version can not be detected and human must manually somehow check it and allow test to continue.",
   :version=>"0.1"},
 "gprs-modem-dialup"=>
  {:depends=>["USB", "GPRS Modem"],
   :destroys_hdd=>false,
   :name=>"USB GPRS Modem Dialup",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SPEED"=>{:default=>"115200", :type=>"int", :comment=>"Line speed"},
     "PPPD_USERNAME"=>
      {:default=>"mts",
       :type=>"string",
       :comment=>"Cell service provider's pppd username"},
     "URL"=>
      {:default=>
        "img-fotki.yandex.ru/getx/10/photoface.359/sevastopol-foto_34661_L",
       :type=>"string",
       :comment=>"URL to download (without http)"},
     "UPLOAD_TRIES"=>
      {:default=>"3",
       :type=>"int",
       :comment=>"Number of tries to upload the file"},
     "UPLOAD_URL"=>
      {:default=>"",
       :type=>"string",
       :comment=>"URL to upload (without http)"},
     "DOWNLOAD_TRIES"=>
      {:default=>"3",
       :type=>"int",
       :comment=>"Number of tries to download the file"},
     "PPPD_TRIES"=>
      {:default=>"4",
       :type=>"int",
       :comment=>"Number of tries to bring pppd up"},
     "UPLOAD_FILE"=>
      {:default=>"/etc/ld.so.cache",
       :type=>"string",
       :comment=>"File to upload"},
     "MD5"=>
      {:default=>"ca530886183b06d0047e0655537327aa",
       :type=>"string",
       :comment=>"MD5 of downloaded file"},
     "DOWNLOAD_MAX_TIME"=>
      {:default=>"60",
       :type=>"int",
       :comment=>"Timeout for the whole download, sec"},
     "APN"=>
      {:default=>"internet.mts.ru",
       :type=>"string",
       :comment=>"Cell service provider's Internet APN"},
     "UPLOAD_MAX_TIME"=>
      {:default=>"120",
       :type=>"int",
       :comment=>"Timeout for file upload, sec"},
     "DEV"=>
      {:default=>"/dev/ttyUSB0",
       :type=>"string",
       :comment=>"Name of device to test"}},
   :description=>"Test GPRS modem, connected using USB",
   :version=>"0.2"},
 "mencoder_hdd"=>
  {:depends=>["CPU", "Memory", "Mainboard", "Disk Controller", "HDD"],
   :destroys_hdd=>true,
   :name=>"Mencoder on hard drive",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"THREADS"=>
      {:default=>"0",
       :type=>"int",
       :comment=>
        "Force using specified number of threads. If equal to zero, then load all available CPUs"},
     "BITRATE"=>
      {:default=>"1000",
       :type=>"int",
       :comment=>"Bitrate of resulting video, KB/sec"},
     "TWOPASS"=>
      {:default=>"false",
       :type=>"boolean",
       :comment=>"Enable two-pass encoding of not"},
     "PRESET"=>
      {:default=>"hq",
       :type=>"string",
       :comment=>
        "Encoding preset. \"lq\" (low quality), \"hq\" (high quality) and \"vhq\" (very high quality) are availabe"},
     "SOURCE"=>
      {:default=>"movie.mpeg2",
       :type=>"string",
       :comment=>"Source transcoding file"},
     "SCALE"=>
      {:default=>"720x480",
       :type=>"string",
       :comment=>"Width and height for rescaling resulting image"}},
   :description=>
    "This benchmark will transcode specified input file to H.264 video, copying without modification audio in (by default) AVI container. You can specify also preset (taken from MPlayerHQ's documentation examples for x264), scaling and bitrate. Two-pass encoding option is available too. This benchmark will use x264's multithreading capabilities to load all CPUs or can run using specified number of threads.",
   :version=>"0.1"},
 "odd_read"=>
  {:depends=>["ODD"],
   :destroys_hdd=>false,
   :name=>"ODD read",
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"MESH_POINTS"=>
      {:default=>"1024",
       :type=>"int",
       :comment=>"Points for meshes for monitoring drive's speed"},
     "TEST_IMAGE_BLOCKS"=>
      {:default=>"332800",
       :type=>"int",
       :comment=>"This images size in blocks (2048 bytes each)"},
     "FORCE_NON_INTERACTIVE"=>
      {:default=>"false",
       :type=>"boolean",
       :comment=>"Force non-interactive mode for already prepared system"},
     "TEST_IMAGE_HASH"=>
      {:default=>"6fa7786eef2e11d36e8bc1663679f161",
       :type=>"string",
       :comment=>"Default image for comparison hash"}},
   :description=>
    "This test checks for workability and correct optical discs reading of ODDs. It detects if disc is already loaded and tries to run test non-interactively (without any humans nearby). It reads needed number of blocks (trying readcd or dd), calculates their checksums and compares with specified. So, we can determine either drives works fine or not. Also, simultaneously it acts as a monitoring, measuring disc reading speed.",
   :version=>"0.1"},
 "fdd"=>
  {:depends=>["Floppy"],
   :destroys_hdd=>false,
   :name=>"FDD read/write",
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"FLOPPY_SIZE"=>
      {:default=>"1440",
       :type=>"int",
       :comment=>"Size of testing floppy, KiB"}},
   :description=>
    "A simple test to determine wheter the floppy drive work or not. It asks a user to insert a floppy disk into drive, then writes some random data on a diskette, clears the cache, reads the data back and compares it to what was written. Process repeats for every FDD available.",
   :version=>"0.1"},
 "net"=>
  {:depends=>["NIC"],
   :destroys_hdd=>false,
   :name=>"Network interface",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"EXCLUDE_MAC"=>
      {:default=>"",
       :type=>"string",
       :comment=>
        "Exclude NICs with MAC addresses that match this regexp from testing"},
     "URL"=>
      {:default=>"3000/test_file",
       :type=>"string",
       :comment=>"Relative to server PORT-URL to be fetched and checked"},
     "TIMEOUT"=>
      {:default=>"15",
       :type=>"int",
       :comment=>"Wait timeout while test file retrieving, sec"},
     "MD5"=>
      {:default=>"805414334eb1d3ff4fdca507ec82098f",
       :type=>"string",
       :comment=>"MD5 checksum for checking"}},
   :description=>
    "This test must load every network interface in system and measure it's download speed. Main requirement: all network interfaces must be connected to one common network. Testing sequence is: 1) Detect and remember what interface is default (from what we are booted up (as common)); 2) Consecutively choosing each interface, check if it's MAC address doesn't exist in \"exclude macs\" test parameter, then either skip it, continuing with another one, or continue to test current inteface; 3) Bring testing interface up, configuring network on it and setting it as a default gateway; 4) Bring down all other interfaces; 5) Get test file from specified URL, measuring download speed; 6) Calculate it's checksum and compare with needed (specified by test parameter). Here, test can fail if an error occurs, otherwise it submits speed benchmarking result and continues to test remaining interfaces; 7) After all interfaces (except the first one) are tested, default interface starts testing: there is no real need in it, when we are booting from network - but it is a simplest way to restore default parameters.",
   :version=>"0.2"},
 "hdd-passthrough"=>
  {:depends=>["CPU", "HDD", "Memory", "Mainboard", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"HDD passthrough",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"JOBS"=>
      {:default=>"16",
       :type=>"int",
       :comment=>
        "Number of parallely running jobs during stress test tree compile"},
     "DISK_GROUP_SIZE"=>
      {:default=>"8",
       :type=>"int",
       :comment=>"Number of disks per group for testing"},
     "MINIMAL_STRESS_TIME"=>
      {:default=>"600",
       :type=>"int",
       :comment=>"Minimal time of stress testing"},
     "RAMDISK_SIZE"=>
      {:default=>"400",
       :type=>"int",
       :comment=>"Size of memory disk for stress tree building, MB"},
     "STRESS_TREE"=>
      {:default=>"linux-2.6.22.5-31-stress.tar.gz",
       :type=>"string",
       :comment=>"Tarball file containing stress test tree"}},
   :description=>
    "HDD passthrough is a stress test that imposes heavy load on main system components. First, it tries to make all HDDs present in the system to appear as separate device nodes - it checks all available RAID controllers, deletes all arrays / disk groups and creates passthrough devices to access individual HDDs if required. Second, it runs badblocks test on every available HDD, running them simulatenously in groups of 8 HDDs by default. Third, it makes a ramdisk filesystem and starts infinite compilation loop in memory, doing so with 16 simultaneous jobs (by default). Test ends successfully after both 1) minimal required stress time passes, 2) all HDDs are checked with badblocks. Test would fail if any bad blocks would be detected on any HDD. Test will usually hang or crash the system on the unstable hardware.",
   :version=>"0.2"},
 "partimage"=>
  {:depends=>["HDD", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"Partimage",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SOURCE"=>
      {:default=>"raw_disk_image",
       :type=>"string",
       :comment=>
        "Absolute of relative path to source raw disk image to be written"},
     "TARGET"=>
      {:default=>"sda",
       :type=>"string",
       :comment=>"Target device name that will be overwritten"}},
   :description=>
    "Actually this is not a real test. It can be used to write prepared raw disk image using Partimage utility.",
   :version=>"0.1"},
 "hdd-smart"=>
  {:depends=>["HDD"],
   :destroys_hdd=>false,
   :name=>"HDD SMART",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"LOGTIME"=>
      {:default=>"120",
       :type=>"int",
       :comment=>"Time between progress updates, sec"}},
   :description=>
    "Simple test for SMART capable hard drives. At first it tries to find is there any SMART capable and correctly working with it drives. Test uses standard smartmontools package. Next, it starts long time full SMART testing on every capable drive and waits for their completion. If everything in SMART log seems good tests passes successfully.",
   :version=>"0.1"},
 "hdparm"=>
  {:depends=>["Disk Controller", "HDD"],
   :destroys_hdd=>false,
   :name=>"HDD benchmark: Hdparm",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"AVG_SAMPLES"=>
      {:default=>"5",
       :type=>"int",
       :comment=>"Number of tests per disc to average for result"}},
   :description=>
    "This benchmark runs on all hard drives in the system sequentially. Every hard drive is benchmarked for the buffered speed and the cached speed using basic hdparm -t and -T tests for several times. The results for every HDD are averaged and presented as benchmark results.",
   :version=>"0.1"},
 "odd_write"=>
  {:depends=>["ODD"],
   :destroys_hdd=>false,
   :name=>"ODD write",
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"WRITE_SPEED_FORCE"=>
      {:default=>"true",
       :type=>"boolean",
       :comment=>"Force write speed using"},
     "TEST_IMAGE_BLOCKS"=>
      {:default=>"332800",
       :type=>"int",
       :comment=>"This images size in blocks (2048 bytes each)"},
     "FORCE_NON_INTERACTIVE"=>
      {:default=>"false",
       :type=>"boolean",
       :comment=>"Force non-interactive mode for already prepared system"},
     "TEST_IMAGE_MD5"=>
      {:default=>"ffffffffffffffffffffffffffffffff",
       :type=>"string",
       :comment=>"Test image MD5 hash"},
     "WRITE_MESSAGE"=>
      {:default=>"Writing test disc",
       :type=>"string",
       :comment=>"Message to print when test will start"},
     "WRITE_SPEED"=>
      {:default=>"10",
       :type=>"int",
       :comment=>"Default write speed if it won't detect"},
     "TEST_IMAGE"=>
      {:default=>"iso/testimage.iso",
       :type=>"string",
       :comment=>"ISO image path (absolute or relative)"}},
   :description=>
    "This test is needed to record discs and at the same time to check corectness of this operation. It can detect if rewritable/recordable media is already inserted and tries to continue non-interactively. After detecting maximal writing speed (it can be forced by an option), blanking if it is rewritable non-blank media, it records specified ISO image. Then, it reads it to compare it's checksum with original one. After all of this we can make a conclusion about drives quality.",
   :version=>"0.1"},
 "cpu"=>
  {:depends=>["CPU"],
   :destroys_hdd=>false,
   :name=>"CPU burn",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"TESTTIME"=>
      {:default=>"1800",
       :type=>"int",
       :comment=>"Total time of CPU testing, sec"}},
   :description=>
    "Basic CPU burn test makes the CPUs execute instructions that rapidly increase processor's temperature in an infinite loop. Test makes special care about used instruction set (to make load as high as possible).",
   :version=>"0.1"},
 "gprs-modem-level"=>
  {:depends=>["USB", "GPRS Modem"],
   :destroys_hdd=>false,
   :name=>"USB GPRS modem signal level",
   :is_interactive=>true,
   :poweroff_during_test=>false,
   :var=>
    {"CHAT_TIMEOUT"=>
      {:default=>"5",
       :type=>"int",
       :comment=>"Timeout for waiting for answer"},
     "DEV"=>
      {:default=>"/dev/ttyUSB0",
       :type=>"string",
       :comment=>"Name of device to test"}},
   :description=>
    "This very simple benchmark intended to reset modem and send special AT-command to get signal level. As it (level) can strongly vary, human can repeat this test as much as he want.",
   :version=>"0.1"},
 "unixbench"=>
  {:depends=>["CPU", "Memory", "Mainboard"],
   :destroys_hdd=>false,
   :name=>"UnixBench benchmark suite",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :description=>
    "This test is a general-purpose benchmark designed to provide a basic evaluation of the performance of a Unix-like system. It runs a set of tests to evaluate various aspects of system performance, and then generates a set of scores. Here, we are using UnixBench version 5 (multi-CPU aware branch) without 2D/3D graphics benchmarks.",
   :version=>"0.1"},
 "whetstone"=>
  {:depends=>["CPU"],
   :destroys_hdd=>false,
   :name=>"CPU benchmark: Whetstone",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{"LOOPS"=>{:default=>"200000", :type=>"int", :comment=>"Loop count"}},
   :description=>
    "A synthetic computing benchmark that measures CPU floating-point performance. Inquisitor uses a C version and runs the specified number of loops, testing each CPU separately, with testing process running affined to particular CPU. Performance rating is in terms of MIPS.",
   :version=>"0.1"},
 "usb-device"=>
  {:depends=>["USB"],
   :destroys_hdd=>false,
   :name=>"USB presence",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"IDVENDOR"=>
      {:default=>"0403",
       :type=>"string",
       :comment=>
        "Filter in only devices with this idVendor (match all if empty)"},
     "COUNT"=>
      {:default=>"1",
       :type=>"int",
       :comment=>"There should be this many devices"},
     "IDPRODUCT"=>
      {:default=>"6001",
       :type=>"string",
       :comment=>
        "Filter in only devices with this idProduct (match all if empty)"}},
   :description=>
    "Tests the presence of designated USB devices. It checks for a count of USB devices that match specified idVendor and idProduct and gives a success if they're equal to COUNT parameter or failure if they're not.",
   :version=>"0.1"},
 "flash"=>
  {:destroys_hdd=>true,
   :name=>"Flash disk",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"SIZE_LIMIT"=>
      {:default=>"2048",
       :type=>"int",
       :comment=>"That is less than this amount is an IDE flash, MiB"}},
   :description=>"Flash disk badblocks test",
   :version=>"0.1"},
 "array-configurator"=>
  {:depends=>["HDD", "Disk Controller"],
   :destroys_hdd=>true,
   :name=>"Array configurator",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"DISK_GROUP_NUMBER"=>
      {:default=>"1",
       :type=>"int",
       :comment=>"Number of disk group (for passthrough configuration)"},
     "ADAPTER_NUMBER"=>
      {:default=>"0",
       :type=>"int",
       :comment=>"Default adapter number (-a option for einarc) to work with"},
     "ADAPTER"=>
      {:default=>"",
       :type=>"string",
       :comment=>
        "Default adapter type to work with. Leave it empty if there only single or several identical adapters present"},
     "CONFIGURATION"=>
      {:default=>"optimal",
       :type=>"string",
       :comment=>
        "Configuration to be passed to einarc. Can be \"clear\", \"optimal\" or \"passthrough\" to run correpsonding raid-wizard utility. Otherwise it will be command line string for einarc. If there are only identical hard drives, then EINARC_DISK1, EINARC_DISK2, etc words can be used to prevent absolute hard drive's identification using"},
     "DISK_GROUP_SIZE"=>
      {:default=>"8",
       :type=>"int",
       :comment=>
        "Number of disks per group for testing (for passthrough configuration)"}},
   :description=>
    "It is not a real test. Simply, it can create specified array configuration on disk controller with hard drives. Currently it passed command line string to einarc, or, if specified \"passthrough\", \"optimal\" or \"clear\", necessary raid-wizard will be used instead.",
   :version=>"0.1"},
 "bonnie"=>
  {:depends=>["HDD"],
   :destroys_hdd=>true,
   :name=>"HDD benchmark: Bonnie",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"DIRECTORIES_NUMBER"=>
      {:default=>"256",
       :type=>"int",
       :comment=>
        "Number of directories to randomly distribute test files among them"},
     "FILESYSTEMS"=>
      {:default=>"ext2 ext3 vfat reiserfs xfs",
       :type=>"string",
       :comment=>"Space-separated list of filesystems to be benchmarked"},
     "NUMBER_OF_FILES"=>
      {:default=>"2",
       :type=>"int",
       :comment=>
        "The number of files for the file creation test. This is measured in multiples of 1024 files"},
     "MAXIMAL_FILE_SIZE"=>
      {:default=>"1024", :type=>"int", :comment=>"Maximal files size, KiB"},
     "MINIMAL_FILE_SIZE"=>
      {:default=>"10", :type=>"int", :comment=>"Minimal files size, KiB"}},
   :description=>
    "This test uses bonnie++ benchmark to test hard drives performance on different filesystems. For every hard drive in a system, test sequently creates specified filesystems on it and then runs bonnie++ benchmark itself. There are two sections to the program\342\200\231s operations. The first is to test the IO throughput in a fashion that is designed to simulate some types of database applications. The  second is to test creation, reading, and deleting many small files in a fashion similar to the usage patterns of programs such as Squid or INN. Bonnie++ tests some of them and for each test gives a result of the amount of work done per second and the percentage of CPU time this took.",
   :version=>"0.2"},
 "mencoder_memory"=>
  {:depends=>["CPU", "Memory", "Mainboard", "Disk Controller", "HDD"],
   :destroys_hdd=>false,
   :name=>"Mencoder in memory",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"THREADS"=>
      {:default=>"0",
       :type=>"int",
       :comment=>
        "Force using specified number of threads. If equal to zero, then load all available CPUs"},
     "BITRATE"=>
      {:default=>"1000",
       :type=>"int",
       :comment=>"Bitrate of resulting video, KB/sec"},
     "TWOPASS"=>
      {:default=>"false",
       :type=>"boolean",
       :comment=>"Enable two-pass encoding of not"},
     "PRESET"=>
      {:default=>"hq",
       :type=>"string",
       :comment=>
        "Encoding preset. \"lq\" (low quality), \"hq\" (high quality) and \"vhq\" (very high quality) are availabe"},
     "SOURCE"=>
      {:default=>"movie.mpeg2",
       :type=>"string",
       :comment=>"Source transcoding file"},
     "SCALE"=>
      {:default=>"720x480",
       :type=>"string",
       :comment=>"Width and height for rescaling resulting image"}},
   :description=>
    "This benchmark will transcode specified input file to H.264 video, copying without modification audio in (by default) AVI container. You can specify also preset (taken from MPlayerHQ's documentation examples for x264), scaling and bitrate. Two-pass encoding option is available too. This benchmark will use x264's multithreading capabilities to load all CPUs or can run using specified number of threads.",
   :version=>"0.1"},
 "db_comparison"=>
  {:depends=>
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
     "USB Mass Storage"],
   :destroys_hdd=>false,
   :name=>"DB to Detects comparison",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :description=>
    "Pauses testing until comparison has been completed on the application server.",
   :version=>"0.1"},
 "db_comparison_fast"=>
  {:depends=>
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
     "USB Mass Storage"],
   :destroys_hdd=>false,
   :name=>"Reference XML to Detects comparison",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>
    {"FILENAMES"=>{:default=>"", :type=>"string", :comment=>"Reference files"},
     "EXCLUDED_MODELS"=>
      {:default=>"",
       :type=>"string",
       :comment=>"Excluded component models from comparison"}},
   :description=>"Compare detects with pre-generated XML.",
   :version=>"0.1"},
 "bytemark"=>
  {:depends=>["CPU", "Memory", "Mainboard"],
   :destroys_hdd=>false,
   :name=>"BYTEmark benchmark suite",
   :is_interactive=>false,
   :poweroff_during_test=>false,
   :var=>{},
   :description=>
    "The BYTEmark benchmark test suite is used to determine how the processor, its caches and coprocessors influence overall system performance. Its measurements can indicate problems with the processor subsystem and (since the processor is a major influence on overall system performance) give us an idea of how well a given system will perform. The BYTEmark test suite is especially valuable since it lets us directly compare computers with different processors and operating systems. The code used in BYTEmark tests simulates some of the real-world operations used by popular office and technical applications. Tests include: numeric and string sort, bitfield working, fourier and assignment manipulations, huffman, IDEA, LU decomposition, neural net.",
   :version=>"0.1"}}

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
 "loadavg"=>
  {:name=>"OS load average",
   :measurement=>"load",
   :description=>
    "GNU/Linux operating system's load average. Load average figures giving the number of jobs in the run queue or waiting for disk I/O.",
   :id=>8},
 "odd-read"=>
  {:name=>"ODD read speed",
   :measurement=>"speed",
   :description=>
    "This is not a real monitoring: it runs only once during odd_read test, that submits drive speed. You can view actual code in client/test/odd_read in generate_speed_results function.",
   :id=>6},
 "thermo"=>
  {:name=>"FTDI thermometer",
   :measurement=>"temperature",
   :description=>
    "This monitoring gets all temperature measurements from FTDI-based USB thermometer.",
   :id=>7},
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
  {:depends=>["OSD"],
   :name=>"OSD detect",
   :description=>
    "Detect optical disk drives using hal-device and try to guess correct vendor name."},
 "memory"=>
  {:depends=>["Memory"],
   :name=>"Memory detect",
   :description=>"Detect DIMMs using SPD, IPMI, DMI, /proc."},
 "tape"=>
  {:depends=>["Tape drive"],
   :name=>"Tape detect",
   :description=>"Detect tape drives using hal-device."},
 "bmc"=>
  {:depends=>["BMC"],
   :name=>"BMC detect",
   :description=>"Get BMC information through ipmitool."},
 "ipmi"=>
  {:depends=>
    ["Chassis", "Mainboard", "Platform", "Power Supply", "SCSI Backplane"],
   :name=>"IPMI parser",
   :description=>"Get some devices info using ipmitool."},
 "usb"=>
  {:depends=>["USB"],
   :name=>"USB devices detect",
   :description=>"Detect some devices that plugged into USB bus."},
 "controller"=>
  {:depends=>["Disk Controller"],
   :name=>"Disk controller detect",
   :description=>
    "Detect disk controllers through einarc and hal-device with required priority."},
 "cpu"=>
  {:depends=>["CPU"],
   :name=>"CPU detect",
   :description=>"Detect CPUs using /proc/cpuinfo."},
 "hdd"=>
  {:depends=>["HDD"],
   :name=>"HDD detect",
   :description=>"Detect hard drives using einarc, smartctl and hal-device."},
 "floppy"=>
  {:depends=>["Floppy"],
   :name=>"Floppy detect",
   :description=>"Detect floppy drives using hal-device."},
 "00lshw-to-xml"=>
  {:depends=>["Video", "NIC", "Fire Wire"],
   :name=>"lshw to xml converter",
   :description=>"Convert lshw output to required XML document."}}

$SOFTWARE_DETECTS = {"iozone"=>{:name=>"Iozone", :description=>"Detect IOzone benchmark version."},
 "linux"=>{:name=>"Linux", :description=>"Detect Linux version."},
 "gas"=>{:name=>"GAS", :description=>"Detect GNU assembler version."},
 "mencoder"=>
  {:name=>"Mencoder", :description=>"Detect MEncoder encoder version."},
 "default_fs"=>
  {:name=>"Default filesystem", :description=>"Detect default filesystem."},
 "tar"=>{:name=>"Tar", :description=>"Detect Tar archiver version."},
 "x264"=>{:name=>"x264", :description=>"Detect x264 libriary version."},
 "gcc"=>{:name=>"GCC", :description=>"Detect GCC version."},
 "gzip"=>{:name=>"Gzip", :description=>"Detect GNU Zip version."},
 "p7zip"=>{:name=>"p7zip", :description=>"Detect p7zip compressor version."},
 "bonnie"=>
  {:name=>"Bonnie++", :description=>"Detect Bonnie++ benchmark version."}}

