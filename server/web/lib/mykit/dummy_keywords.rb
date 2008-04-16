module Mykit

class Keywords

class Components
	HDD		= 0
	FDD		= 1
	ODD		= 2
	CPU		= 3
	CTRL		= 4
	MB		= 5
	RAM		= 6
	NET		= 7
	PWR		= 8
	CASE		= 9 
	BBU		= 10
	AMM		= 11
	PLAT		= 12
	ENC		= 13
	HID		= 14
	SOFT		= 15

	@@names = ['HDD', 'FDD', 'ODD', 'CPU', 'CTRL', 'M/B', 'RAM', 'NET', 'PWR', 'CASE', 'BBU', '...', 'PLF', 'ENC', 'HID', 'SOFT']

	def self.[](i)
		@@names[i]
	end
end

class Properties
	CAPACITY 	= 0
	SPEED		= 1
	SIZE		= 2
	POWER		= 3
	CACHE		= 4
	FREQUENCY	= 5
	THROUGHPUT	= 6
	CHANNELS	= 7
	FORMAT		= 8
	UNITS		= 9
	CONNECTOR	= 10

	@@names = ["Capacity", "Speed", "Size", "Power", "Cache size", "Frequency", "Throughput", "Channels", "Format", "Units", "Connector"]

	def self.[](i)
		@@names[i]
	end
end

EMBED = {
	Components::HDD		=> [],
	Components::FDD		=> [],
	Components::ODD		=> [],
	Components::CPU		=> [],
	Components::CTRL	=> [],
	Components::MB		=> [Components::CTRL, Components::NET],
	Components::RAM		=> [],		
	Components::NET		=> [],
	Components::PWR		=> [],
	Components::CASE	=> [Components::PWR, Components::ENC],
	Components::BBU		=> [],
	Components::AMM		=> [],
	Components::PLAT	=> [Components::MB, Components::CTRL, Components::PWR, Components::CASE, Components::NET, Components::ENC],
	Components::ENC		=> [],
	Components::HID		=> [],
	Components::SOFT	=> []
}

			    #HDD  #FDD  #ODD  #CPU  #CTRL #MB   #RAM  #NET  #PWR  #CASE #BBU  #AMM  #PLAT #ENC  #HID  #SOFT
PROPS =[	           [1,    1,    0,    0,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0],  #CAPACITY
		           [1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0],  #SPEED
		           [0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0],  #SIZE
		           [0,    0,    0,    0,    0,    0,    0,    0,    1,    1,    0,    0,    1,    0,    0,    0],  #POWER
		           [1,    0,    0,    1,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],  #CACHE
		           [0,    0,    0,    1,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0],  #FREQUENCY
		           [1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],  #THROUGHPUT
		           [0,    0,    0,    0,    1,    0,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0],  #CHANNELS
		           [0,    1,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],  #FORMAT
		           [0,    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,    1,    1,    0,    0,    0],  #UNITS
		           [1,    1,    1,    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,    0,    0,    0],  #CONNECTOR
]
			    #HDD  #FDD  #ODD  #CPU  #CTRL #MB   #RAM  #NET  #PWR  #CASE #BBU  #AMM  #PLAT #ENC
WORDS ={'SCSI' 		=> [1,    0,    0,    0,    1,    1,    0,    0,    0,    1,    0,    0,    1,    1,    0,    0],
#	''		=> [0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],
}
			    #HDD  #FDD  #ODD  #CPU  #CTRL #MB   #RAM  #NET  #PWR  #CASE #BBU  #AMM  #PLAT #ENC  #HID  #SOFT
UNITS ={'Gb' 		=> [0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],
#	''		=> [0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,    0],
} 

MEASURES={'Gb' 		=> [Properties::CAPACITY],
}



MAX_DISTANCE = 1.5
SAFE_DISTANCE = 1.0
KW_DISTANCE = 1.0
COMP_DISTANCE = 2
SPAN_DISTANCE = 3
COMP_MARGIN = 100.0 # think about margin later

OMIT_FROM_COMPARISON = ['PWR', '...', 'ENC', 'CASE', 'WRN', 'SOFT']
GROUP_TRANS = 
{
	'Memory'		=> 'RAM',
}

end

end	
