module Timespans

        TIMESPANS = {
                'ordering' => 24 * 3600,
                'warehouse' => 48 * 3600,
                'acceptance' => 2 * 3600,
                'assembling' => 6 * 3600,
                'testing' => 48 * 3600,
                'cheching' => 24 * 3600,
                'packaging' => 24 * 3600,
        }

        def default_timespan
                TIMESPANS[stage]
        end

end

